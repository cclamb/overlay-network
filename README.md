#Staring the Overlay Simulator

This is an overlay network simulator.  To use:

    $ git clone https://cclamb@github.com/cclamb/overlay-network.git
    $ cd overlay-network
    $ bundle exec bin/overlay -s

When the overlay simlulator boots, you'll see statuses on the various HTTP servers created.  The servers are running in the background, you still have control of your shell.  Sometimes the shell doesn't seem to return, but if you hit enter, the command line will reappear.

When started, you have started five separate processes all running HTTP servers on a variety of different ports.  These servers are running independendly and are not controlled by the forking process.  A couple of things happen:
* _bin/.pids_: This file contains the process IDs of the forked processes and is required to terminate them.
* _forking_: Processes are forked separated from the forking process.

This is important - if _bin/.pids_ exists, the overlay script will not fork servers.  If the system terminates in correctly, you'll need to manually remove the _bin/.pids_ file and kill any running _bin/overlay_ processes.

# Demonstrating the Overlay Simulator

Next, we'll see how it works.  The overlay starts off with the connecting link at _secret_.  Nodes are on ports 4570 and 4571.  The node on 4570 has local access to the _test_ bundle, which contains content at a variety of sensitivity levels.  This is the primary experimental bundle.  The node on 4571 has local access to the test-1 bundle, which is essentially a control bundle.  Each bundle contains an XML file and a license file.

