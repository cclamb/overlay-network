require_relative '../carp/node'
require_relative '../trout/router'

module Core

  Content_Root_Base = "#{File.dirname __FILE__}/../../etc/content-"

  def Core::process_child port, router_url, ctx_mgr_url, content_root
    puts "\t ==>> node up on port #{port}...\n"
    Carp::Core::Node.start :router => router_url, \
      :ctx_mgr => ctx_mgr_url, \
      :content_root => content_root, \
      :ctx => { :port => port, :logging => true }
    exit!
  end

  def Core::process_router port, nodes, ctx_mgr_url, router_urls
    puts "\t==>> router up on port #{port}...\n"
    puts nodes
    Trout::Router.start :nodes => nodes, \
      :ctx_mgr => ctx_mgr_url, \
      :routers => router_urls, \
      :ctx => { :port => port, :logging => true }
    exit!
  end

  def Core::spawn links, nets, base_port = 4567
    pids = []
    port = base_port

    router_ports = []
    for i in 1 .. nets.size
      router_ports.push port
      port += 1
    end

    net_cnt = 0

    original_router_ports = router_ports.clone
    nets.each do |number_of_nodes|

      # reserve for router
      # router_port = port
      # port += 1
      router_port = router_ports.pop
      raise 'bad port number' if router_port == nil

      router_url = "http://localhost:#{router_port}"

      node_ports = []
      number_of_nodes.times do |cnt|
        node_ports.push port

        content_root = "#{Content_Root_Base}#{net_cnt}"
        net_cnt += 1
        puts "ROOT => #{content_root} : #{net_cnt}"

        pid = fork
        if pid == nil
          process_child port, router_url, nil, content_root
        else
          puts "In parent! child pid: #{pid}"
          Process.detach pid
          pids.push pid
        end
        port += 1
      end

      nodes = []
      node_ports.each do |node_port|
        nodes.push "http://localhost:#{node_port}"
      end

      pid = fork
      if pid == nil
        other_routers = original_router_ports.clone
        other_routers.delete router_port
        process_router router_port, nodes, nil, other_routers
      else
        puts "In parent! child pid: #{pid}"
        Process.detach pid
        pids.push pid
      end

    end
    pids
  end

  def Core::clean pids
    puts "Killin me childs like da boss!\n"
    pids.each do |pid|
      Process.kill :INT, pid
    end
  end

end