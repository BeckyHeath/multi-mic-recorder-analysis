import numpy as np
import matplotlib.pyplot as plt

# Adapted from: pysdr.org/content/doa.html
# From 8 Microphone in a linear array example with music 
# Edited to be circular array 
# Becky Heath 2023 

# Recording/ positioning properties of the array
sample_rate = 16000
N = 10000 # number of samples to simulate
radius = 0.05 
num_mics = 6

#Nr = 8 # 8 elements for linear array
#d = 0.5 # for linear array

# Microphone positions in a circular array
theta_mics = np.linspace(0, 2 * np.pi, num_mics, endpoint=False)
mic_positions = radius * np.exp(1j * theta_mics)


# Create tone: 
t = np.arange(N)/sample_rate
f_tone = 0.02e6
tx = np.exp(2j*np.pi*f_tone*t)


# Define onset angles - here we're using 3 
theta1 = 20 / 180 * np.pi # convert to radians
theta2 = 25 / 180 * np.pi
theta3 = -40 / 180 * np.pi

# Calclulat the signal vector. This is the signal arriving from a specific
# angle given above 

# -2j * np.pi is the phase shift
# d represents the spacing 
# np.arrange(Nr) is a way of indexing each of the microphones, i.e. generating 
#               a signal for each of the microphones 
# Adjusts to the right angle of arrival 
# Reshape for analysis. 
s1 = np.exp(-2j * np.pi * np.arange(N) * np.sin(theta1))
s2 = np.exp(-2j * np.pi * np.arange(N) * np.sin(theta2))
s3 = np.exp(-2j * np.pi * np.arange(N) * np.sin(theta3))

# Linear: s = np.exp(-2j * np.pi * d * np.arange(Nr) * np.sin(theta3)).reshape(-1,1)

#Old way: 
# # Combine the signals
# r = s1 @ tone1 + s2 @ tone2 + 0.1 * s3 @ tone3

# # Generate and add noise to the signals
# n = np.random.randn(Nr, N) + 1j*np.random.randn(Nr, N)
# r = r + 0.05*n # 8xN


# Received signal at each microphone
received_signals = np.zeros((num_mics, N), dtype=np.complex128)
for i, position in enumerate(mic_positions):
    received_signal = s1 * np.exp(1j * np.angle(position))
    noise = 0.1 * (np.random.randn(N) + 1j * np.random.randn(N))
    received_signals[i] = received_signal + noise

# Plotting
for signal in received_signals:
    plt.plot(np.real(signal[:50]))

plt.show()




# PERFORM MUSIC ANALYSIS

# Construct the received signal matrix
R = received_signals @ received_signals.conj().T

# Perform eigenvalue decomposition
w, v = np.linalg.eig(R)

# Sort eigenvectors based on eigenvalues
eig_val_order = np.argsort(np.abs(w))
v = v[:, eig_val_order]

# Noise subspace
num_expected_signals = 1
V = v[:, :num_mics - num_expected_signals]

# Perform MUSIC analysis
theta_scan = np.linspace(0, 2 * np.pi, 1000)
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
ax.set_thetamin(0)
ax.set_thetamax(360)
plt.show()