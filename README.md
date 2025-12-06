# 🎨 Provably Fair Raffle Draw — Best of 7  
This project contains the exact script used to run the raffle draw for the **Art Supply Giveaway**.

The draw is **provably fair**, **transparent**, and **fully reproducible** by anyone.

---

## 📌 What “Provably Fair” Means  
This raffle uses:

- An **open-source script** (included here)  
- A **public randomness seed** (posted before the draw)  
- A **deterministic random number generator** (same seed → same result)

This means:

➡️ **Nobody can rig or influence the winner**  
➡️ **Anyone can replay the draw themselves**  
➡️ **You can independently verify that the winner was real**

If you run the same script with the same seed and same number of entrants,  
you will always get the **exact same winner, same round history, same graph, same everything**.

---

## 🧠 How the Randomness Works  
The script accepts a **seed string**, which can be anything publicly verifiable, such as:

- A Bitcoin block hash  
- A Random.org value  
- A stock index closing number  
- A timestamped public value

The script converts this seed string into a number using:

`SHA-256(seed_string) → integer`


This integer is fed directly into Ruby’s RNG via `srand`, creating a **deterministic random sequence**.

Because of this:

> **Same seed string = same RNG sequence = same winner**  
> (100% reproducible)

---

## 🏆 How the Winner Is Chosen  
We use a **Best-of-7** format:

- The script draws random numbers between `1` and the number of entrants  
- Each time a number is drawn, it earns **1 point**  
- The first number to reach **4 points** wins  
  (because 4 wins out of 7 possible is a “best of 7”)

A live-updating **vertical bar graph** shows the top 5 numbers each round.

---

## 🎥 Transparency  
For the real draw:

- The **seed string** was published publicly *before* running the script  
- The **terminal session was screen-recorded**  
- The entire source code is included here  

This ensures the draw could not be manipulated.

---

## ▶️ How to Reproduce the Draw Yourself  
You can verify the winner by running:

```bash
ruby main.rb <entrants> "<seed_string>"
```