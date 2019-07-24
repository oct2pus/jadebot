package markov

// Duplicates are provided for sanity of anyone who wants to host their own
// JadeBot and wants to do customize her, as well as futureproofing.
// Never know when you want to do more complex input/output.

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math/rand"
	"strings"

	"github.com/mb-14/gomarkov"
)

var (
	chain *gomarkov.Chain
	order = 2
	// Pesters is an array of possible starting values,
	// values are duplicated for weighing probability of occurance.
	pesters = []string{"GG:", "GG:", "GG:", "GG:", "GG:", "GG:", "GG:", "GG:",
		"GG:", "GG:", "GG:", "GG:", "JADE:", "JADE:", "JADE:", "JADE:",
		"JADE:", "JADE:", "JADE:", "JADE:", "JADESPRITE:", "JADESPRITE:",
		"JADESPRITE:", "?GG:"}
)

// Load loads a model.json file.
func Load(inputFile string) error {
	var c gomarkov.Chain
	data, err := ioutil.ReadFile(inputFile)
	if err != nil {
		return err
	}
	err = json.Unmarshal(data, &c)
	if err != nil {
		return err
	}
	c.Order = order
	chain = &c
	return nil
}

// LoadAndReturnChain returns a gomarkov.Chain pointer.
func LoadAndReturnChain(inputFile string, markovOrder int) (*gomarkov.Chain,
	error) {
	var c gomarkov.Chain
	data, err := ioutil.ReadFile(inputFile)
	if err != nil {
		return &c, err
	}
	err = json.Unmarshal(data, &c)
	c.Order = markovOrder
	return &c, err
}

// Generate returns a line of markov chain dialog.
func Generate(randomSeed int64) (string, error) {
	rand.Seed(randomSeed)
	tokens := []string{gomarkov.StartToken, pesters[rand.Intn(len(pesters))]}
	for tokens[len(tokens)-order] != gomarkov.EndToken {
		next, err := chain.Generate(tokens[(len(tokens) - order):])
		if err != nil {
			return "", err
		}
		tokens = append(tokens, next)
	}
	return fmt.Sprint(strings.Join(tokens[1:len(tokens)-order], " ")),
		nil
}

// GenerateFromChain returns a line of markov chain dialog from a gomarkov.Chain pointer.
// You should have markovOrder-1 markovSeed parameters (none for markovOrder = 1).
func GenerateFromChain(markovChain *gomarkov.Chain,
	markovOrder int, randomSeed int64, markovSeed ...string) (string, error) {
	rand.Seed(randomSeed)
	tokens := []string{gomarkov.StartToken}
	for _, seed := range markovSeed {
		tokens = append(tokens, seed)
	}
	for tokens[len(tokens)-markovOrder] != gomarkov.EndToken {
		next, err := markovChain.Generate(tokens[(len(tokens) - markovOrder):])
		if err != nil {
			return "", err
		}
		tokens = append(tokens, next)
	}
	return fmt.Sprint(strings.Join(tokens[1:len(tokens)-markovOrder], " ")),
		nil
}

// GenerateMany generates as many inputs as you put in.
func GenerateMany(amount int, randomSeed int64) ([]string, error) {
	output := make([]string, 0)
	for i := 0; i < amount; i++ {
		markov, err := Generate(randomSeed)
		if err != nil {
			return output, fmt.Errorf("error on loop %v: %v", i, err)
		}
		output = append(output, markov)
	}

	return output, nil
}
