require 'rubygems'
require 'cwiid'
require 'ostruct'
wiimote = WiiMote.new
wiimote.rpt_mode = WiiMote::RPT_BTN | WiiMote::RPT_ACC


@opts=OpenStruct.new
@opts.output_mode = :dec #:graph
@opts.graph_scale = 4 # length = (255/graph_scale).to_i
@opts.acc_range = 1
@opts.state = :active

def get_acc(wiimote)
    wiimote.acc
end

def graph(value, size=(255/@opts.graph_scale), min=-3, max=3) 
  #min=(255-opts.acc_range)/2
  #max=255-min
  ("*"*(value*(size/255.0))).ljust((size),".")
end

def norm_acc(acc)
  acc.map! do |n|
    val = "%1.2f"%((n-126)/26.0)  if @opts.output_mode == :dec
    val = graph(n)             if @opts.output_mode == :graph
    val
  end 
  acc << ((acc[0].to_f**2)+(acc[1].to_f**2)+(acc[2].to_f**2))**0.5 if @opts.output_mode == :dec
  acc
end

def build_dataset(wiimote)
  out = Array.new
  out << "%10.5f" % Time.now.to_f
  out << norm_acc(get_acc(wiimote))
  out.flatten.join(",")
end

def change_state
  @state=:active if @state==:sleeping
  @state=:sleeping if @state == :active
end

begin 
    wiimote.get_state
    puts build_dataset(wiimote) if @opts.state == :active 
  #  change_state unless wiimote.buttons != WiiMote::BTN_2
    sleep 0.04
end while wiimote.buttons != WiiMote::BTN_1
