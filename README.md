# lua-lsw

a lua based client for [leaseweb api](http://developer.leaseweb.com/api-docs/)

![leaseweb](https://www.leaseweb.com/sites/all/themes/leaseweb/logo.svg "leaseweb")

# usage

    lswcli.lua <module> [<bareMetalId>] [<args>]

    MODULES:
      lease     <bareMetalId> 'http://files.example.org/boot-this.ipxe'
      list
      password  <bareMetalId>
      reboot    <bareMetalId>
      rescue    <bareMetalId>
      rmleases  <bareMetalId>
      show      <bareMetalId>

# examples

## list all servers

    > lswcli.lua list
    >> baremetal
       - location:  AMS-01
         - name/id: ROFL001 / 123456
           hw:      Hp DL180 G5 / Intel Quad-Core Xeon L5410 (2x4@2330 Mhz)
                    32GB ram / 4x300 GB SAS  disks
         - name/id: ROFL002 / 234567
           hw:      Hp DL120 G6 / Intel Quad-Core Xeon X3440 (1x4@2530 Mhz)
                    16GB ram / 4x1 TB SATA  disks

## create a lease to boot special ipxe instructions

    > lswcli.lua lease 234567 'http://ipxe.example.org/ubuntu-install.ipxe'

## show server information

    > lswcli.lua show 234567
    >> Hp DL120 G6 (ROFL002 / 234567)

       - contract
         sla:       Basic - 24x7x24
         price:     11.81
         start:     Oct 1, 2017
         end:       -
         term:      1 month(s)

       - hardware
         cpu:       1x4 @ 2530 Mhz (Intel Quad-Core Xeon X3440)
         ram:       16GB
         disks:     4x1 TB SATA 
         mac:
           - DE:AD:BE:AF:00:01
           - DE:AD:BE:AF:00:02
           - DE:AD:BE:AF:00:03
         switch:    1 / open
         power:     on

       - ipmi
         ip:        a.b.c.d
         netmask:   255.255.255.x
         gateway:   a.b.c.d

       - ip

         ip:        a.b.c.d
         gateway:   a.b.c.d
         netmask:   255.255.255.x
         ptr:       reverse.example.org
         nullroute: disabled

         ip:        a.b.c.d
         gateway:   a.b.c.d
         netmask:   255.255.255.x
         ptr:       -
         nullroute: enabled

       - leases

         ip:        a.b.c.d
         mac:       DE:AD:BE:AF:00:01
         - options
           Bootfile Name: undionly.kpxe
           DNS Servers: a.b.c.d
           Boot Server Host Name: a.b.c.d
           Bootfile Name: http://ipxe.example.org/ubuntu-install.ipxe

## remove all leases

    > lswcli.lua rmleases 234567

## reboot server

    > lswcli.lua reboot 234567

## enable rescue system

    > lswcli.lua rescue 234567
    >> available images
       1) FreeBSD Rescue Image (amd64)
       2) GRML Linux Rescue Image (amd64)

       > choose an image: 2

## show server passwords

    > lswcli.lua password 123456
    >> passwords
       default:     my_passw0rd!
       rescue:      my_passw0rd!
