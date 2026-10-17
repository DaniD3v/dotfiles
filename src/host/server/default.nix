{
  imports = [
    ./hardware.nix
    ./disko.nix

    ./containers
    ./network.nix
    ./nftables.nix
    ./netbird.nix
    ./vm.nix
  ];

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      AllowUsers = [
        "notyou"
        "eschb"
      ];
    };
  };
  users.users.notyou-minimal.openssh.authorizedKeys.keyFiles = [
    ../../user/notyou-minimal/ssh_key.pub
  ];
  users.users.eschb = {
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ ../../user/eschb/ssh_key.pub ];
  };

  dotfiles = {
    users = {
      "notyou-minimal" = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "input"
        ];
      };
    };

    location = {
      timezone = "Europe/Vienna";
      locale = "en_US.UTF-8";
    };
  };
}
