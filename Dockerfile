FROM scratch
# Add the base image
ADD systemimage.tar.gz /

# Also add the NI software feeds
ADD ni-software.conf /etc/opkg
ADD ni-third-party.conf /etc/opkg
ADD ni-arch.conf /etc/opkg

# post-inst type stuff
# TODO: we should make an image type without /boot and other kernel stuff?
RUN rm -rf /boot \
	&& setcap CAP_SYS_TIME+ep /sbin/hwclock.util-linux \
	&& opkg-key populate \
	&& /etc/init.d/populateconfig start \
	&& echo 'VARIANT_ID=container' >> /etc/os-release

CMD [ "bash" ]
