# Home Assistant docker image for Kirkwood/ARMV5TE
###### This is not an official docker image of [Home Assistant](https://github.com/home-assistant) since `armel` platform is not supported.

This docker image allows you to run Home Assistant on Kirkwood boxes (GoFlex, Pogoplug, Sheevaplug, NSA325, etc.) and on ARMv5 platform in general. Everything that runs [bodhi's debian](https://forum.doozan.com/read.php?2,12096) for these boxes SHOULD run it but you will need to recompile bodhi's kernel to include support for memory cgroup since Docker needs it to properly run this image or any linux image.

It doesn't differ much from a normal Home Assistant docker image and it also has all of the components preinstalled from [requirements_all.txt file in the Home Assistant Core repo](https://github.com/home-assistant/core/blob/dev/requirements_all.txt). This one is important since installing all of these components during runtime when there's a new integration needed would be quite unpleasant due to long compilation times. If I missed something, please open an issue and I'll do my best to include any missing packages or fix issues with the image itself.

Use the same command as the one recommended by Home Assistant to run this image.
Example:
> docker run -d --name homeassistant --privileged --restart=unless-stopped -e TZ=Europe/Warsaw -v /root/.homeassistant:/config --network=host rara64/kirkwood-homeassistant

I'm running this image on my modded NSA325 NAS with an external SSD as a boot drive along with an OpenMediaVault installation. Running OS on an external SSD/HDD is CERTAINLY RECOMMENDED for a good experience. I hadn't had much luck with a USB 3.0 thumb drive - to put it short, performance was lacking. I'm running Docker from docker.io debian package on my device. Despite device limitations (512MB of RAM and single-core Marvell 88F6282 clocked at 1.6GHz), it runs well once everything is up and running. I have a bunch of automations, a few integrations and active data logging with a mobile app connected.

A new image should be automatically built and pushed to docker hub every week if there's a new release of Home Assistant available. Although if you want you can still download the Dockerfile from this repo and built the image on your PC using the following command:
> docker buildx build --platform=linux/arm/v5 --load --allow security.insecure .

## About the project
I started this project to make Home Assistant run on a NSA325 NAS I had lying around since Raspberry Pi's were hard to come by and expensive at that time (and still are). It took over a month to figure it all out. A good chunk of that time, I was compiling the latest Cargo for ARMV5TE platform since it (along with Rust) is required to compile MANY of the pip packages needed by HASS components. Getting all of these things to work since not everything is precompiled for this platform was a headache ... but here we are and I'm happy with the result! :tada: Kudos to bodhi and everyone involved in maintaining these Kirkwood boxes by providing a way to mod them. This wouldn't have been possible without these efforts.
