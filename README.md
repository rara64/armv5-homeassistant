# Home Assistant docker image for ARMv5TE
#### This is not an official docker image of [Home Assistant](https://github.com/home-assistant) since `linux/arm/v5` platform is not supported.

Image allows you to run Home Assistant on ARMv5 platform and is mainly build for NAS devices based on Kirkwood architecture.

Everything that runs [bodhi's debian](https://forum.doozan.com/read.php?2,12096) for these boxes should run this image but you will need to recompile bodhi's kernel to include support for memory cgroup since Docker needs it for Linux images. All components from [requirements_all.txt file in the Home Assistant Core repo](https://github.com/home-assistant/core/blob/dev/requirements_all.txt) are preinstalled which greatly improves the experience on old Kirkwood boxes. In case I missed something, please open an issue and I'll do my best.

Use a similar command as the one provided in Home Assistant install guide to run the image:
> docker run -d --name homeassistant --privileged --restart=unless-stopped -e TZ=MY_TIME_ZONE -v PATH_TO_YOUR_CONFIG:/config --network=host rara64/armv5-homeassistant

A new image should be automatically built and pushed to Docker Hub every week if there is a new release of Home Assistant available. Nevertheless, you can still download the `Dockerfile.local` file from this repo and build the image on your PC using the following command:
> docker buildx build --platform=linux/arm/v5 --load --allow security.insecure .

## My usecase

This image currently runs on my modded NSA325 NAS alongside OpenMediaVault install. Running OS on an external SSD/HDD is certainly recommended for a good experience. I hadn't had much luck with a USB 3.0 thumb drive - to put it short, performance was lacking. I installed docker from docker.io debian package. 

Despite device limitations (512MB of RAM and single-core Marvell 88F6282 clocked at 1.6GHz), it runs well once everything is up and running. I have a bunch of stuff set up and constant data logging with a mobile app connected.

## About the project
I started this project to make Home Assistant run on a NAS I had lying around since Raspberry Pi's were hard to come by and expensive at the time (and still are). It took over a month to figure it all out. A good chunk of that time, I was trying to compile the latest Cargo for ARMv5TE platform since it along with Rust is required to compile many of the python packages needed by HASS components. Getting all of these things to work since not everything is precompiled for this platform was a headache ... but here we are and I'm happy with the result!

Kudos to bodhi and everyone involved in maintaining these Kirkwood boxes. This wouldn't have been possible without these efforts.
