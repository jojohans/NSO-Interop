An NSO interop testing image
============================

Build a NSO interop testing container image.

Prerequisites
-------------

NSO-installer, e.g. from https://developer.cisco.com/site/nso/
YANG-models for the device you want to test.

Steps
-----
1. Drop the NSO installer image into the resources directory.
2. Drop the device YANG-models into the resources/yangs directory.
3. Create the NSO Interop testing image

`$ docker build --tag nso-interop:<version> .`

   The Dockerfile has a number of ARGs that lets you override things
   line NSO-version target IP-address and port etc, the defaults can
   be changed by passing one or more `--build-arg='parameter=value'` to
   the `docker build` command.  See the Dockerfile for details.

4. Run the docker image and expose the NETCONF and internal IPC ports.

`$ docker run -it --rm -p 2022:2022 -p 4569:4569 --init --hostname nso-interop --name nso-interop nso-interop:<version>`

   In order to help troubleshooting it makes sense to mount logs and
   DrNED Examiner directories from outside of the container:

`$ docker run -d --rm -p 2022:2022 -p 4569:4569 --mount type=bind,source=/absolute/path/to/interop-logs,target=/interop/logs --mount type=bind,source=/absolute/path/to/interop-xmnr,target=/interop/xmnr --init --hostname nso-interop --name nso-interop nso-interop:<version>`

   Assuming the interop-logs and interop-xmnr volumes already exist in current working directory.

4. Start the CLI and create the NETCONF NED as described in `Chapter 4
   NETCONF NED Builder` in the `NSO 5.4 NED Development` guide.
