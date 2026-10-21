# Containers — availability boundary

This package does not bootstrap container images or install container SDKs.
Use the existing Worker runtime for ordinary backend logic; see
[runtime and infrastructure](runtime-and-infra.md).

If a requested feature requires native binaries, a headless browser or a
long-running container, first inspect the existing project configuration. If the
capability is not already provisioned, report the limitation and ask for a
platform-supported environment. Do not add a Dockerfile that fetches a new base
image or packages, and do not install an SDK from the editing sandbox.

For an already provisioned container project, preserve its dependency and image
configuration. Scope all work to the requested website, keep credentials out of
source and logs, and verify deployment with `website_status` before reporting
success. Do not imply that this package supplies a container runtime.
