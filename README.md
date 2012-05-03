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

So, queries to the server on 4570 will _not be controlled as they don't cross a domain boundary_.  Ergo, you can use this as a control element.  Queries for the _test_ bundle to 4571 _will be managed_.

So let's first query 4570 for test:

    $ curl -v http://localhost:4570/content/test

    * About to connect() to localhost port 4570 (#0)
    *   Trying ::1... Connection refused
    *   Trying 127.0.0.1... connected
    > GET /content/test HTTP/1.1
    > User-Agent: curl/7.22.0 (i686-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3
    > Host: localhost:4570
    > Accept: */*
    > 
    < HTTP/1.1 200 OK
    < X-Frame-Options: sameorigin
    < X-XSS-Protection: 1; mode=block
    < Content-Type: application/xml;charset=utf-8
    < X-Overlay-Port: 4570
    < X-Overlay-Role: node
    < Content-Length: 889
    < Connection: keep-alive
    < Server: thin 1.3.1 codename Triple Espresso
    < 
    <content>
      <license>
        <policy>

      <!-- This is specific to source data in an artifact. -->
      <entity name="source">
        <permissions>
          <activity-restrictions>
            <restriction property="transmit" function="greater_than">
              secret
            </restriction>
          </activity-restrictions>
        </permissions>
      </entity>

      <!-- This is specific to operational data in an artifact. -->
      <entity name="operational">
        <permissions>
          <activity-restrictions>
            <restriction property="transmit" function="greater_than">
              unclassified
            </restriction>
          </activity-restrictions>
        </permissions>
      </entity>
      
    </policy>
      </license>
      <artifact>
        <test>
      <operational>This is operational data (e.g. S).</operational>
      <source>This is source data (e.g. TS).</source>
      This is unlabeled content (e.g. UC).
    </test>
      </artifact>
    </content>

We're using verbose mode here with `curl` which shows us headers, post data, and response codes.  Here, we have a response showing the policy information (in the _license_ element) and the requested data (in the _artifact_ element).  Note the permissions and restrictions in the license and how that corresponds to material in the artifact section.  This data is unfiltered.

Now let's execute the same query against port 4571, which retreives this content via a montitored cross-domain connection:

    $ curl -v http://localhost:4571/content/test

    <?xml version="1.0"?>
    <content>
      <license>
        <policy>

      <!-- This is specific to source data in an artifact. -->
      

      <!-- This is specific to operational data in an artifact. -->
      <entity name="operational">
        <permissions>
          <activity-restrictions>
            <restriction property="transmit" function="greater_than">
              unclassified
            </restriction>
          </activity-restrictions>
        </permissions>
      </entity>
      
    </policy>
      </license>
      <artifact>
        <test>
      <operational>This is operational data (e.g. S).</operational>
      
      This is unlabeled content (e.g. UC).
    </test>
      </artifact>
    </content>

Note that here I have truncted the status information of the request for brevity's sake.  Here, we have a license segment in the response and an artifact segment.  Notice that the license no longer has and data regarding the source element (except for comments) and the content section also contains no source data.  The connection is running at _secret_ and that information cannot traverse that link, ergo it has been redacted.

Now we will run unclassified on the link.  To do this, let's first check the status by querying the Context Manager.  The Context Manager will return JSON indicating the status:

    $ curl http://localhost:4567/status
    {"level":"secret"}

(Note I've dropped the `-v` option from _curl_, so I'm no longer running in verbose mode, so I no longer have HTTP status information, header information, or POST data displayed.)

So we are running at _secret_, as expected.  Let's change that to unclassified:

    $ curl -d "level=unclassified" http://localhost:4567/status
    $ curl http://localhost:4567/status
    {"level":"unclassified"}

Note the `-d "level=unclassified"` addition to curl above.  This executes an HTTP POST with the data tuple (level, unclassified).

We can now execute a query against 4571 again:

    $ curl http://localhost:4571/content/test

    <?xml version="1.0"?>
    <content>
      <license>
        <policy>

      <!-- This is specific to source data in an artifact. -->
      

      <!-- This is specific to operational data in an artifact. -->
      
      
    </policy>
      </license>
      <artifact>
        <test>
      
      
      This is unlabeled content (e.g. UC).
    </test>
      </artifact>
    </content>

Now we only have unclassified content, and all data related to classified elements within the license has been removed.

Now, let's change the link to top_secret, and run again:

    $ curl -d "level=unclassified" http://localhost:4567/status
    $ curl http://localhost:4567/status
    {"level":"top_secret"}

    $ curl http://localhost:4571/content/test

    <?xml version="1.0"?>
    <content>
      <license>
        <policy>

      <!-- This is specific to source data in an artifact. -->
      <entity name="source">
        <permissions>
          <activity-restrictions>
            <restriction property="transmit" function="greater_than">
              secret
            </restriction>
          </activity-restrictions>
        </permissions>
      </entity>

      <!-- This is specific to operational data in an artifact. -->
      <entity name="operational">
        <permissions>
          <activity-restrictions>
            <restriction property="transmit" function="greater_than">
              unclassified
            </restriction>
          </activity-restrictions>
        </permissions>
      </entity>
      
    </policy>
      </license>
      <artifact>
        <test>
      <operational>This is operational data (e.g. S).</operational>
      <source>This is source data (e.g. TS).</source>
      This is unlabeled content (e.g. UC).
    </test>
      </artifact>
    </content>

Comparing this to the the original query against the local repository via the first query against the node running on 4570, we see that all the content is returned over the secure link.

