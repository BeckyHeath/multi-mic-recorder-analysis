import numpy as np
import matplotlib.pyplot as plt

# Adapted from: pysdr.org/content/doa.html
# From 8 Microphone in a linear array example with music 
# Edited to be circular array using content from: 
# https://github.com/krakenrf/krakensdr_doa/blob/main/_sdr/_signal_processing/kraken_sdr_signal_processor.py#L938
# 
# Becky Heath 2023 

# Recording/positioning properties of the array
sample_rate = 16000
N = 10000  # number of samples to simulate
radius = 0.0463 
num_mics = 6

#Nr = 8 # 8 elements for linear array
#d = 0.5 # for linear array

# Microphone positions in a circular array
theta_mics = np.linspace(0, 2 * np.pi, num_mics, endpoint=False)
mic_positions = radius * np.exp(1j * theta_mics)

# Find microphone angles
angles_deg = np.linspace(0, 360, num_mics, endpoint=False)  # Angles for each microphone
angles_rad = np.deg2rad(angles_deg)

# Create tone
t = np.arange(N) / sample_rate
f_tone = 2000
tx = np.exp(2j * np.pi * f_tone * t).reshape(1,-1)

# Define onset angles - here we're using 1 
theta_deg = 45
theta1 = np.deg2rad(theta_deg)  # convert to radians

# Compute phase shifts for each microphone
phase_shifts = np.exp(-2j * np.pi * radius * np.sin(angles_rad - theta1))

# Construct signal vector
s1 = phase_shifts.reshape(-1, 1) 

# Combine for a single tone
r = s1 @ tx

# Add noise
n = np.random.randn(num_mics, N) + 1j*np.random.randn(num_mics, N)
r = r + 0.05*n # 8xN

# Plot
plt.plot(np.asarray(r[0,:]).squeeze().real[0:200]) # the asarray and squeeze are just annoyances we have to do because we came from a matrix
plt.plot(np.asarray(r[1,:]).squeeze().real[0:200])
plt.plot(np.asarray(r[2,:]).squeeze().real[0:200])
plt.plot(np.asarray(r[3,:]).squeeze().real[0:200]) 
plt.plot(np.asarray(r[5,:]).squeeze().real[0:200])

plt.show()


# PERFORM MUSIC ANALYSIS
num_expected_signals = 1    # Change this if you have more than 1 

# Construct the covariance matrix 
R = r @ r.conj().T 

# Do eigenvalue decomposition
w, v = np.linalg.eig(R)

# Find and sort first order of magnitude of eigenvalues
eig_val_order = np.argsort(np.abs(w))
v = v[:, eig_val_order]

# Noise subspace is the rest of the eigenvalues
V = np.zeros((num_mics, num_mics - num_expected_signals), dtype=np.complex64) 

for i in range(num_mics - num_expected_signals):
    V[:, i] = v[:, i]


# Perform MUSIC analysis
# between -180 and +180
theta_scan = np.linspace(-1*np.pi, np.pi, 1000)

results = []

for theta_i in theta_scan:
    s = np.exp(-2j * np.pi * np.arange(num_mics) * np.sin(theta_i)).reshape(-1, 1)
    metric = 1 / (s.conj().T @ V @ V.conj().T @ s) 
    metric = np.abs(metric.squeeze())
    metric = 10 * np.log10(metric)
    results.append(metric)
results -= np.max(results)

# Plot the beam pattern 
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.plot(theta_scan, results)
ax.set_theta_zero_location('N')
ax.set_theta_direction(-1)
ax.set_rlabel_position(30)
ax.set_thetamin(-180)
ax.set_thetamax(180)
plt.show()


# Notes from old code: 


# If using mor than one tone you'd use: 
# s1 = np.exp(-2j * np.pi * np.arange(N) * np.sin(theta1))
# s2 = np.exp(-2j * np.pi * np.arange(N) * np.sin(theta2))
# s3 = np.exp(-2j * np.pi * np.arange(N) * np.sin(theta3))
 
# If the array is linear you'd use instead
# s = np.exp(-2j * np.pi * d * np.arange(Nr) * np.sin(theta3)).reshape(-1,1)

#Old way: 
# # Combine the signals
# r = s1 @ tone1 + s2 @ tone2 + 0.1 * s3 @ tone3

# # Generate and add noise to the signals
# n = np.random.randn(Nr, N) + 1j*np.random.randn(Nr, N)
# r = r + 0.05*n # 8xN

# If using more than one tone you'd use: 
# theta1 = 20 / 180 * np.pi # convert to radians
# theta2 = 25 / 180 * np.pi
# theta3 = -40 / 180 * np.pi
