package main

import (
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/websocket"
	"github.com/rs/cors"
)

var addr = flag.String("addr", "0.0.0.0:8080", "http service address")

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

var chatHistory []string

var onlineUsers = []string{
	"User0",
	"User1",
	"User2",
	"User3",
	"User4",
}

func echo(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()


	for {
		_, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		log.Printf("recv: %s", message)

		if strings.HasPrefix(string(message), "!") {
			switch {
			case strings.HasPrefix(string(message), "!history"):
				indexStr := strings.TrimPrefix(string(message), "!history ")
				index, err := strconv.Atoi(indexStr)
				if err != nil || index < 1 || index > len(chatHistory) {
					c.WriteMessage(websocket.TextMessage, []byte("Error: Please request a valid history index (1 to "+strconv.Itoa(len(chatHistory)-1)+")"))
					continue
				}
				err = c.WriteMessage(websocket.TextMessage, []byte(chatHistory[len(chatHistory)-index]))
				if err != nil {
					log.Println("write:", err)
					break
				}
			case strings.HasPrefix(string(message), "!date"):
				response := "<pre>Server date is: " + time.Now().Format(time.RFC3339) + "</pre>"
				err = c.WriteMessage(websocket.TextMessage, []byte(response))
				if err != nil {
					log.Println("write:", err)
					break
				}
			case strings.HasPrefix(string(message), "!users"):
				response := "<pre>Online users: " + strings.Join(onlineUsers, ", ") + "</pre>"
				err = c.WriteMessage(websocket.TextMessage, []byte(response))
				if err != nil {
					log.Println("write:", err)
					break
				}
			case strings.HasPrefix(string(message), "!help"):
				response := "<pre>Commands:\n" +
					"!write [message]: send a message\n" +
					"!date: get the server date\n" +
					"!users: get the online users\n" +
					"!help: list available commands</pre>"
				err = c.WriteMessage(websocket.TextMessage, []byte(response))
				if err != nil {
					log.Println("write:", err)
					break
				}
			case strings.HasPrefix(string(message), "!write"):
				message = []byte(strings.TrimPrefix(string(message), "!write "))
				chatHistory = append(chatHistory, "User0: " + string(message))
				err = c.WriteMessage(websocket.TextMessage, []byte("User0: "+string(message)))
				if err != nil {
					log.Println("write:", err)
					break
				}
			default:
				response := "Invalid command. Type !help for a list of commands."
				err = c.WriteMessage(websocket.TextMessage, []byte(response))
				if err != nil {
					log.Println("write:", err)
					break
				}
			}
		} else {
			response := "Invalid command. Type !help for a list of commands."
			err = c.WriteMessage(websocket.TextMessage, []byte(response))
			if err != nil {
				log.Println("write:", err)
				break
			}
		}
	}
}

func allHistory(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte(strconv.Itoa(len(chatHistory)-1)))
}

func main() {
	flag.Parse()
	log.SetFlags(0)

	flagData, err := ioutil.ReadFile("flag.txt")
	if err != nil {
		log.Fatal("Failed to read flag file:", err)
	}
	flagStr := string(flagData)
	chatHistory = append(chatHistory, "User5: Aha! You're right, I was here before all of you! Here's your flag for finding me: " + flagStr)

	extraChatMessages := []string{
		"User4: This chat is awesome!",
		"User1: I agree, it's really cool.",
		"User2: I'm enjoying it too!",
		"User3: Me too! Great conversations happening here.",
		"User1: Wait, has someone been here before us?",
		"User2: Oh hey User0, was it you? You can use !help as a command to learn more :)",
	}
	chatHistory = append(chatHistory, extraChatMessages...)

	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "index.html")
	})

	mux.HandleFunc("/chatroom.js", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "chatroom.js")
	})

	mux.HandleFunc("/echo", echo)
	mux.HandleFunc("/allHistory", allHistory)

	handler := cors.Default().Handler(mux)
	log.Fatal(http.ListenAndServe(*addr, handler))
}
