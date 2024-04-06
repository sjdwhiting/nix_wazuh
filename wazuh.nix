{ stdenv,
makeWrapper,
lib ,
pkgs,
fetchurl,
autoconf,
automake,
libtool,
openssl,
wget,
bzip2,
gcc,
curl,
cacert,
policycoreutils,
...
}:

stdenv.mkDerivation rec {
    pname = "wazuh-agent";
    version = "4.7.3";
    src = fetchurl {
      url = "https://github.com/wazuh/wazuh/archive/v4.7.3.tar.gz"; # package download url;
      sha256 = "292b9cf53a07fc79d95e4ef45c7887b1fd85017d07b7c1c80a1f0afbdad53073";
    };

    nativeBuildInputs = [ pkgs.makeWrapper curl cacert];

       buildInputs = with pkgs; [
        python312
        gcc
        gnumake
        libcxx
        curl
        automake
        autoconf
        libtool
        openssl
        cmake
        perl
    ];

        configurePhase = ''
        cat <<EOF >> ./etc/preloaded-vars.conf
            USER_LANGUAGE="en"
            USER_NO_STOP="y"
            USER_INSTALL_TYPE="agent"
            USER_DIR="/var/ossec"
            USER_DELETE_DIR="n"
            USER_ENABLE_ACTIVE_RESPONSE="y"
            USER_ENABLE_SYSCHECK="y"
            USER_ENABLE_ROOTCHECK="y"
            USER_ENABLE_OPENSCAP="y"
            USER_ENABLE_SYSCOLLECTOR="y"
            USER_ENABLE_SECURITY_CONFIGURATION_ASSESSMENT="y"
            USER_AGENT_SERVER_IP=127.0.0.1
            USER_CA_STORE="no"
        EOF
    '';
    

    buildPhase = ''
        echo "Starting install phase"
        mkdir -p $out/bin
        echo "Extracting the src"
        tar -xzf $src
        echo "Copying source files"
        cp -r $sourceRoot/* $out/
        echo "Changing directory to src"
        echo $out
        cd $out
        pwd
        echo "Running make deps"
        cd src
        echo "Creating external directory first..."
        mkdir external

        make deps


        
        echo "Running make -C src TARGET=agent"
        echo "Current directory:"
        echo "Out directory:"
        echo $out
        pwd
        echo "Current directory contents:"
        ls -l
        cd ..
        make -C src TARGET=agent
        echo "Now running make -C src install"
        make -C src install
        makeWrapper $out/bin/wazuh-agent $out/bin/wazuh-agent --set WAZUH_MANAGER=
    '';



    postInstall = ''
        bash install.sh
    '';

    meta = {
        description = "Wazuh agent for NixOS";
        homepage = "https://wazuh.com";
    };

}
