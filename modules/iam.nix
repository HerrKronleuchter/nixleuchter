_: {
  users.users.kronleuchter = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAb6rbZq2Yi1KYq5UmPxcKx/nTTzM/o7RvrbWihB7o8kgdzMXnJIasJC35c2fg+gvxe/uI5I2YhmNhxazreoJwaeQE+DLbX0QIGr1Al86sMIhrPrsIxvgRlQvSPC2BEMJvLJuCOo4d0cj3RWXfH6zl/qDGUZbWcACjTy5CMROtjezVXGg== kronleuchter"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

}
