package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"math/rand"
	"strings"
	"time"

	"github.com/mb-14/gomarkov"
)

var (
	order      = 2
	beginnings = []string{"GG:", "GG:", "GG:", "GG:", "GG:", "JADE:", "JADE:", "JADE:", "JADESPRITE:", "?GG:"}
)

func main() {
	train := flag.Bool("train", false, "Train the markov chain")
	flag.Parse()
	if *train {
		chain, err := buildModel()
		if err != nil {
			fmt.Printf("error: %v\n", err)
			return
		}
		saveModel(chain)
	} else {
		chain, err := loadModel()
		if err != nil {
			fmt.Printf("error: %v\n", err)
			return
		}
		generatePester(chain)
	}
}

func buildModel() (*gomarkov.Chain, error) {
	pesters, err := ioutil.ReadFile("jade.txt")
	if err != nil {
		return nil, err
	}
	chain := gomarkov.NewChain(order)
	for _, pester := range strings.Split(string(pesters), "\n") {
		chain.Add(strings.Split(pester, " "))
	}
	return chain, nil
}

func saveModel(chain *gomarkov.Chain) {
	obj, err := json.Marshal(chain)
	if err != nil {
		fmt.Printf("error: %v\n", err)
	}
	err = ioutil.WriteFile("model.json", obj, 0644)
	if err != nil {
		fmt.Printf("error: %v\n", err)
	}
}

func loadModel() (*gomarkov.Chain, error) {
	var chain gomarkov.Chain
	data, err := ioutil.ReadFile("model.json")
	if err != nil {
		return &chain, err
	}
	err = json.Unmarshal(data, &chain)
	chain.Order = order
	return &chain, err
}

func generatePester(chain *gomarkov.Chain) {
	rand.Seed(time.Now().UnixNano())
	tokens := []string{gomarkov.StartToken, beginnings[rand.Intn(len(beginnings))]}
	for tokens[len(tokens)-order] != gomarkov.EndToken {
		next, err := chain.Generate(tokens[(len(tokens) - order):])
		if err != nil {
			fmt.Printf("error: %v\n", err)
			return
		}
		tokens = append(tokens, next)
	}
	fmt.Println(strings.Join(tokens[1:len(tokens)-2], " "))
}
