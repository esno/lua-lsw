# lua-lsw

a lua based client for [leaseweb api](http://developer.leaseweb.com/api-docs/)

![leaseweb](https://www.leaseweb.com/sites/all/themes/leaseweb/logo.svg "leaseweb")

# binding

## install

  > luarocks install lua-lsw

## usage

    % > lua
    Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
    >
    > lswMetals = require('leaseweb.bareMetals')
    > metals = lswMetals:init('<api-key>').listServers()
    >
    > for k, v in pairs(metals[1]) do if type(v) == 'function' then print(k) end end
    retrieveSwitchPortStatus
    retrieveBareMetal
    closeSwitchPort
    updateIp
    retrieveLease
    retrieveBandwidthUsage
    deleteLeases
    retrievePowerStatus
    retrieveDataTrafficUsage
    listIps
    updateBareMetal
    listLeases
    retrieveIp
    openSwitchPort
    reboot
    deleteLease
    retrieveInstallationStatus
    retrieveNetworkUsage
    createLease
    retrievePassword

# cli

## install

  > luarocks install lua-lswcli

## usage

### authentication

lsw cli is asking for the api key if config file doesn't exists.
As soon as you entered the api key it will persisted in `~/.config/lsw/rc.lua`

    token > 689990ad-ca3f-4d35-b299-0c493a86e985
    welcome to leaseweb api client. help for help
    > :q

### common

    % > lsw
    welcome to leaseweb api client. help for help
    > help
    the following commands are available
        bareMetal               manage your bare metal servers
    > bareMetal
    bareMetal > help
    the following commands are available
        info            prints detailed information about the selected server
        ls              shows all bareMetal servers
        ref             update server reference
        select          select a server
        status          prints information about server status
    bareMetal > ls
    123456  ROFL001/Bare Metal      rofl1.example.org
    234567  ROFL002/Bare Metal      rofl2.example.org
    bareMetal > status
    no server selected
    bareMetal > select
    1) ROFL001 / rofl1.example.org
    2) ROFL002 / rofl2.example.org
    select > 1
    bareMetal [ROFL001] > status
    power:  on              switch: open

    a.b.c.d:                routed
    b.c.d.e:                routed
    c.d.e.f:                routed
    ::1:                    routed
    bareMetal [ROFL001] > select 
    1) ROFL001 / rofl1.example.org
    2) ROFL002 / rofl2.example.org
    select > 2
    bareMetal [ROFL002] > status
    power:  on              switch: open

    d.e.f.g:                routed
    e.f.g.h:                routed
    bareMetal [ROFL002] > exit
    > exit
