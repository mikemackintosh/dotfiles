# Extension Downloader
function dlext() {
  local extension_id=$1
  mkdir -p /tmp/extension/
  curl -L -o "/tmp/extension/$extension_id.zip" "https://clients2.google.com/service/update2/crx?response=redirect&os=mac&arch=x86-64&nacl_arch=x86-64&prod=chromecrx&prodchannel=stable&prodversion=44.0.2403.130&x=id%3D$extension_id%26uc"
  unzip -d "/tmp/extension/$extension_id-source" "/tmp/extension/$extension_id.zip"
  cd /tmp/extension/$extension_id-source
}
