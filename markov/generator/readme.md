# Generator

Generator is a helper program to generate a model.json that JadeBot can accept.
You must bring your own `pester.txt`. The one used in JadeBot proper is based on the actual Pesterlogs/Dialoglog/Spritelogs featuring Jade Harley/Jadesprite. Multiline pesters are cut off due to a flaw in my method of acquiring it. You can take the logs from anything really,.

## Built-in Assumptions

### Order

The model is for a 2nd order markov chain (i.e. it takes into account words in chains of 2's for determining the output.), you can change the `order` variable to change the order value of your generated `model.json`. As a note, the `generatePester()` func assumes its a 2nd order model, and you will need to modify it accordingly.

### Pester.txt

`pester.txt` is a newline delimited file. Every new line is considered a seperate sentence for the model.

### JadeBot

JadeBot assumes a 2nd order Markov Chains; JadeBot also assumes all pesters begin with `GG:`, `?GG:`, `JADE:`, or `JADESPRITE:`. You will need to modify all functions in the `markov` folder accordingly if you want to use a `model.json` that don't follow this pattern.

## Building

```
go build
```

## Usage

```
./generator -train
```

Trains a model based on your pester.txt file; creates a `model.json` file.

```
./generator
```

Produces a sentence based on your `model.json`.

## Acknowledgement

Much of the code is based on the [fakernews](https://github.com/mb-14/gomarkov/tree/master/examples/fakernews) example for gomarkov. As such it feels inappropriate to GPL this code. This helper program is [licenced under the MIT Licence](LICENCE).