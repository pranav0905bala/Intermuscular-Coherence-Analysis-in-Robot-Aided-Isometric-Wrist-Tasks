# Intermuscular-Coherence-Analysis-in-Robot-Aided-Isometric-Wrist-Tasks
This work was towards my thesis, where I developed an experimental framework to analyze intermuscular coherence (IMC) from EMG signals during robot-aided isometric wrist tasks. A pilot study was conducted to evaluate how neuromuscular coordination varies with wrist posture, interaction force, and movement direction, contributing toward EMG-based biomarkers for motor impairment assessment.

**Original Thesis Title:**  
*Intermuscular Coherence during Robot-Aided Isometric Wrist Tasks: A Pilot Study on the Role of Wrist Posture and Interaction Force*

# 🧠 Intermuscular Coherence Analysis in Robot-Aided Wrist Tasks Using EMG

## 📌 Overview
Developed an experimental framework to analyze **intermuscular coherence (IMC)** from EMG signals during robot-aided isometric wrist tasks. Conducted a pilot study to evaluate how neuromuscular coordination varies with wrist posture, interaction force, and torque direction, contributing toward EMG-based biomarkers for motor impairment assessment.

---

## ⚙️ System Overview

### 🏗️ Experimental Setup

A robot wrist exoskeleton used to perform controlled isometric torque generation tasks. The system enables repeatable experiments while synchronizing EMG signals with mechanical outputs.

---

### 🖥️ Real-Time GUI

Custom-built interface providing real-time feedback:
- Torque represented as a 2D vector  
- Target regions guide user input  
- Enables consistent task execution across trials  

---

## 📡 EMG Signal Processing Pipeline

End-to-end pipeline for EMG analysis:
- Multi-channel EMG acquisition (forearm and arm muscles)  
- Bandpass + high-pass filtering  
- Segmentation of steady-state contraction windows  
- Spectral analysis using Welch’s method  
- Computation of **magnitude-squared coherence**  

---

## 📊 Intermuscular Coherence Results

Coherence computed across all muscle pairs to quantify neuromuscular coupling.

**Key metrics:**
- Beta band analysis (15–30 Hz)  
- Statistical thresholding (95% confidence)  
- Z-score normalization for comparison across conditions  

---

## 🧪 Experimental Design

- **Task:** Isometric wrist torque generation  
- **Platform:** 2-DOF wrist exoskeleton  
- **Conditions:**
  - Neutral posture (baseline)  
  - Flexed vs extended wrist posture  
  - Active vs reactive force interaction  
  - Multiple torque directions (FE/RUD axes)  

---

## 🧠 Key Findings

- Higher coherence observed during **extension torque** vs flexion  
- Strong coupling in **wrist and finger flexor muscle pairs**  
- Neuromuscular coordination varies with:
  - Wrist posture  
  - Interaction dynamics (active vs reactive)  
- Not all muscle pairs exhibit significant coherence → indicates task-specific coordination  

---

## 🛠️ Tech Stack

- MATLAB  
- Signal Processing (EMG filtering, FFT, coherence)  
- Data Analysis & Visualization  
- Experimental Design (Human-in-the-loop systems)  

---

## 📈 Core Contribution

- Built a complete **EMG coherence analysis pipeline**  
- Applied **frequency-domain methods** to quantify neuromuscular coordination  
- Performed **statistical normalization and comparative analysis** across experimental conditions  
- Generated interpretable metrics for muscle coupling  

---

