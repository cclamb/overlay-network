require_relative '../carp/node'
require_relative '../trout/router'
require_relative '../koi/context_manager'

module Core

  Content_Root_Base = "#{File.dirname __FILE__}/../../etc/content-"

  def Core::process_child port, router_url, ctx_mgr_url, content_root
    Carp::Core::Node.start :router => router_url, \
      :ctx_mgr => ctx_mgr_url, \
      :content_root => content_root, \
      :ctx => { :port => port, :logging => true }
    exit!
  end

  def Core::process_router port, nodes, ctx_mgr_url, router_urls
    Trout::Router.start :nodes => nodes, \
      :ctx_mgr => ctx_mgr_url, \
      :routers => router_urls, \
      :ctx => { :port => port, :logging => true }
    exit!
  end

  def Core::process_context_manager port
    Koi::ContextManager.start \
      :ctx => { :port => port, :logging => true }
    exit!
  end

  def Core::spawn links, nets, base_port = 4567
    pids = []
    port = base_port

    cm_port = port
    port += 1
    pid = fork
    if pid == nil
      Process::daemon true, false
      process_context_manager cm_port
    else
      Process.detach pid
      pids.push pid
    end

    router_ports = []
    for i in 1 .. nets.size
      router_ports.push port
      port += 1
    end

    net_cnt = 0

    original_router_ports = router_ports.clone
    nets.each do |number_of_nodes|

      router_port = router_ports.pop
      raise 'bad port number' if router_port == nil

      router_url = "http://localhost:#{router_port}"

      node_ports = []
      number_of_nodes.times do |cnt|
        node_ports.push port

        content_root = "#{Content_Root_Base}#{net_cnt}"
        net_cnt += 1

        pid = fork
        if pid == nil
          Process::daemon true, false
          process_child port, \
            router_url, \
            "http://localhost:#{cm_port}/status", \
            content_root
        else
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
        process_router router_port, \
          nodes, \
          "http://localhost:#{cm_port}/status", \
          other_routers
      else
        Process.detach pid
        pids.push pid
      end

    end
    pids
  end

  def Core::clean pids
    pids.each do |pid|
      Process.kill :INT, pid
    end
  end

end