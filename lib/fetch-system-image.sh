# This is sourced by build-container.
#
# inputs: ROOT_DIR, VERSION, CONTAINER_BUILD_DIR, OPKG
# outputs: FULL_VERSION

OPKG_BASE_DIR=$CONTAINER_BUILD_DIR-opkg
mkdir -p $OPKG_BASE_DIR

if [ "x${OPKG}" = "x" ]; then
	OPKG=$(which opkg || true)
	if [ "x${OPKG}" = "x" ]; then
		echo "Error: No opkg in path! We need one, or set OPKG to the path of the opkg executable."
		exit 1
	fi
fi

DIST_FEED=http://download.ni.com/ni-linux-rt/feeds/dist

OPKG_CONF=$OPKG_BASE_DIR/opkg.conf

echo "# automatically-generated opkg.conf for dist package retrieval" > $OPKG_CONF
echo "src/gz dist-feed ${DIST_FEED}" >> $OPKG_CONF

# make sure the architectures are right for the image
DOCKER_ARCH=$(docker version --format '{{.Server.Arch}}')
case $DOCKER_ARCH in
	amd64)
		echo "arch core2-64 2" >> $OPKG_CONF
		;;
	arm)
		echo "arch cortexa9-vfpv3 2" >> $OPKG_CONF
		;;
	*)
		echo "Unknown docker architecture '${DOCKER_ARCH}'"
		exit 1
		;;
esac

echo "arch all 1" >> $OPKG_CONF

OPKG_OFFLINE_ROOT_DIR=$OPKG_BASE_DIR/root
OPKG_TMP_DIR=$OPKG_BASE_DIR/tmp
OPKG_CACHE_DIR=$OPKG_BASE_DIR/cache

rm -rf $OPKG_OFFLINE_ROOT_DIR $OPKG_TMP_DIR $OPKG_CACHE_DIR
mkdir -p $OPKG_OFFLINE_ROOT_DIR $OPKG_TMP_DIR $OPKG_CACHE_DIR

OPKG_CL="$OPKG -f $OPKG_CONF -o $OPKG_OFFLINE_ROOT_DIR -t $OPKG_TMP_DIR --cache $OPKG_CACHE_DIR"

PKG=dist-nilrt-grub

$OPKG_CL update

# Download and "install" (offline) the dist package.
# This is made somewhat tricky because we want to find, e.g., the "21.0.0" package,
# but the actual opkg version is something like "21.0.0.49309-0+f157", and opkg doesn't
# support anything like the '~=' compatible-release clause (e.g. PEP 440). Soooo we sort of
# hack it-- the user specifies "21.0.0", we concatenate a .65536 to make it "21.0.0.65536"
# and that should end up being close enough to compatible-release with our versioning scheme.
$OPKG_CL install "$PKG<=${VERSION}.65536"

# Figure out the full version of what it was we just downloaded.
FULL_VERSION=$($OPKG_CL list-installed $PKG | awk -F ' ' '{print $3}' | sed 's/\-.*//;')

mv $OPKG_OFFLINE_ROOT_DIR/.syscfg-action/*/systemimage.tar.gz $CONTAINER_BUILD_DIR/systemimage.tar.gz
mv $OPKG_OFFLINE_ROOT_DIR/etc/natinst/share/systemimage_files/ni-software.conf $CONTAINER_BUILD_DIR/ni-software.conf
mv $OPKG_OFFLINE_ROOT_DIR/etc/natinst/share/systemimage_files/ni-third-party.conf $CONTAINER_BUILD_DIR/ni-third-party.conf
