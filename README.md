# Amplitude & Angle Modulation — DSB, SSB, and FM in MATLAB/Simulink

Coursework project from **Principles of Communication Systems (PCS)**, University of Tehran.
Implements DSB-SC and SSB modulation/demodulation from scratch (no `hilbert()`, no built-in ideal filter),
evaluates receiver impairments (phase offset, frequency offset, realistic Butterworth filtering instead of
an ideal brick-wall LPF), and analyzes FM bandwidth via Carson's rule with a Simulink PLL demodulator.

All numbers below were verified by actually running the scripts (GNU Octave 8.4, `signal` package) on the
sample voice clips in `mp3 files/`.

## Files

| File | What it does |
|---|---|
| `part1_dsb.m` | DSB-SC: modulate, coherent demod, impairment sweep |
| `part2_ssb.m` | SSB (USB & LSB) via Hilbert-transform modulator, impairment sweep |
| `part3_fm_carson.m` | FM modulation index & Carson bandwidth calculation |
| `fmquestion3.slx` | Simulink: FM modulator + custom multiplier-based PLL demodulator |
| `manualHilbert.m` | Hilbert transform implemented via FFT (used to build SSB) |
| `idealLPF.m` | Brick-wall low-pass filter implemented in the frequency domain |
| `plotTimeFreq.m` | Shared time-domain / spectrum plotting helper |
| `first.m` | Loads and normalizes the course-provided voice clips |
| `part0_q4_myvoice.m` | Records, normalizes, and inspects a custom voice sample |
| `plot_all_signals.m` | Time/frequency-domain inspection of all input clips |
| `mp3 files/` | Input voice clips used by the scripts above |
| `report.pdf` | Full coursework report (Persian) — derivations, discussion, Simulink write-up |

To run: open MATLAB (or Octave with the `signal` package) in this folder and run `part1_dsb.m`, `part2_ssb.m`,
or `part3_fm_carson.m` directly — they expect `mp3 files/`, `idealLPF.m`, `manualHilbert.m`, and `plotTimeFreq.m`
to be on the path, i.e. in the same folder or added via `addpath`.

## What's implemented

- **`manualHilbert.m`** — Hilbert transform via FFT: build the signal's spectrum, multiply by `-j·sign(f)`, invert.
  Used to build the SSB modulator (`m·cos(ωt) ∓ m̂·sin(ωt)`) instead of calling MATLAB's `hilbert()`.
- **`idealLPF.m`** — brick-wall low-pass filter implemented directly in the frequency domain (FFT → zero out
  `|f| > W` → IFFT), used as the "ideal receiver" baseline before comparing against a real 6th-order Butterworth.
- **DSB coherent receiver**, swept against:
  - local-oscillator **phase error**: π/2, π/4, π/3 rad
  - local-oscillator **frequency error**: 10%, 1%, 0.1% of the carrier
  - **ideal LPF vs. realistic 6th-order Butterworth** LPF
- **SSB (USB & LSB) coherent receiver**, same impairment sweep, plus a `2×` gain correction since a single
  sideband carries half the power of the corresponding DSB signal.
- **FM / Carson's rule** — modulation index, Carson bandwidth, and predicted occupied spectrum, checked against
  a Simulink model where the FM demodulator is built from a multiplier-based phase detector (PLL) rather than
  a canned demod block, with the derivation of why it's equivalent to standard PLL demod written up in the report.

## Results

**DSB-SC** (`fc = 15 kHz`, `W = 4 kHz`, noise σ² = 0.01, voice clip `m_t1.mp3`):

| Condition | MSE | SNR |
|---|---|---|
| Ideal coherent demod | 0.0227 | 5.78 dB |
| Phase error π/2 | 0.0868 | — |
| Phase error π/4 | 0.0371 | — |
| Phase error π/3 | 0.0494 | — |
| Freq error 10% of fc | 0.0974 | — |
| Freq error 1% of fc | 0.0985 | — |
| Freq error 0.1% of fc | 0.0971 | — |
| 6th-order Butterworth LPF | 0.0227 | — |

**SSB** (`fc = 15 kHz`, `W = 4 kHz`, noise σ² = 0.01, voice clip `m_a1.mp3`):

| Condition | MSE | SNR |
|---|---|---|
| USB, ideal coherent demod | 0.00337 | 10.92 dB |
| LSB, ideal coherent demod | 0.00337 | 10.92 dB |
| Phase error π/2 | 0.0868 | — |
| Phase error π/4 | 0.0278 | — |
| Phase error π/3 | 0.0451 | — |
| Freq error 10% of fc | 0.0869 | — |
| Freq error 1% of fc | 0.0869 | — |
| Freq error 0.1% of fc | 0.0879 | — |
| 6th-order Butterworth LPF | 0.00316 | — |

SSB gives a noticeably lower baseline MSE than DSB here — consistent with the theory: DSB's demodulated
noise band is twice as wide as SSB's before filtering, since both sidebands fold onto baseband, so its
output SNR is worse for the same input noise power.

**FM / Carson's rule** (`fc = 10 kHz`, `kf = 2500 Hz/V`, `fm = 2 kHz`, `Am = 1`):

- Peak deviation Δf = 2500 Hz
- Modulation index β = 1.25
- Carson bandwidth B = 9000 Hz
- Predicted occupied band: 5.5 kHz – 14.5 kHz (checked against the Spectrum Analyzer output of the Simulink model)

## Known issue (fixed)

An earlier version of `part2_ssb.m` had a bug: the demodulator multiplied by an undefined variable `z`
instead of the actual received signal `r`, so it only ran without erroring because of a leftover variable
from a previously executed script — meaning the original SSB "ideal case" numbers computed that way weren't
actually derived from the SSB signal. Fixed in this version; the numbers above are from the corrected code.

## Origin

Developed as coursework for *Principles of Communication Systems*, University of Tehran.

## Notes

- `report.pdf` has the full mathematical derivations and discussion behind each result and is a good reference,
  but isn't required to run the code.
- `first.m`, `part0_q4_myvoice.m`, and `plot_all_signals.m` are audio prep/inspection utilities and aren't
  required to reproduce the DSB/SSB/FM results above.
