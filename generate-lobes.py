import numpy as np
import matplotlib.pyplot as plt
import scipy 

# Adapted from: pysdr.org/content/doa.html
# From 8 Microphone in a linear array example with music 
# Edited to be circular array using content from: 
# https://github.com/krakenrf/krakensdr_doa/blob/main/_sdr/_signal_processing/kraken_sdr_signal_processor.py#L938
# 
# Becky Heath 2023 
# 
# With significant contribution from Marc Lichtman 


# Recording/positioning properties of the array

sample_rate = 16000
N = 100000  # number of samples to simulate
radius = 0.0463 
num_mics = 6

f_tone1 = 8000 # Signal frequency


# Find inter-mic distance for Uniform Circular Array (UCA)
sep_angle = 360/num_mics
mic_sep = np.sqrt(radius**2 + radius**2 - 2*radius*radius*np.cos(np.radians(sep_angle)))
wavelength = 343/f_tone1 # speed of sound in m/s, DIFFERNET FOR EACH TONE!!!
mic_sep /= wavelength # make mic_sep normalized to wavelength


# Microphone positions in a circular array
theta_mics = np.linspace(0, 2 * np.pi, num_mics, endpoint=False)
mic_positions = radius * np.exp(1j * theta_mics)


# Find microphone angles
angles_deg = np.linspace(0, 360, num_mics, endpoint=False)  # Angles for each microphone
angles_rad = np.deg2rad(angles_deg)


# Create tone
t = np.arange(N) / sample_rate
tx1 = np.exp(2j * np.pi * f_tone1 * t).reshape(1,-1)

#f_tone2 = 4000
#tx2 = np.exp(2j * np.pi * f_tone2 * t).reshape(1,-1)


# Define onset angles
theta1 = np.deg2rad(30)  # convert to radians
#theta2 = np.deg2rad(-35)


# Compute phase shifts for each microphone
# phase_shifts = np.exp(-2j * np.pi * radius * np.sin(angles_rad - theta1))
#s1 = phase_shifts.reshape(-1, 1) 

to_r = 1.0 / (np.sqrt(2.0) * np.sqrt(1.0 - np.cos(2.0 * np.pi / num_mics))) # convert UCA inter element spacing back to its radius
x = mic_sep * to_r * np.cos(2 * np.pi / num_mics * np.arange(num_mics))
y = -1 * mic_sep * to_r * np.sin(2 * np.pi / num_mics * np.arange(num_mics))
s1 = np.exp(1j * 2 * np.pi * (x * np.cos(theta1) + y * np.sin(theta1))).reshape(-1, 1)
#s2 = np.exp(1j * 2 * np.pi * (x * np.cos(theta2) + y * np.sin(theta2))).reshape(-1, 1)


# Create received signal
n = np.random.randn(num_mics, N) + 1j*np.random.randn(num_mics, N)
r = s1 @ tx1 + 0.5*n

#r = s1 @ tx1 + s2 @ tx2 + 0.05*n # 6xN
print("r shape is: ", r.shape)
print("r type is: ", type(r))

# Plot
if False:
    plt.plot(np.asarray(r[0,:]).squeeze().real[0:200]) # the asarray and squeeze are just annoyances we have to do because we came from a matrix
    plt.plot(np.asarray(r[1,:]).squeeze().real[0:200])
    plt.plot(np.asarray(r[2,:]).squeeze().real[0:200])
    plt.plot(np.asarray(r[3,:]).squeeze().real[0:200]) 
    plt.plot(np.asarray(r[5,:]).squeeze().real[0:200])
    plt.show()


# Try MVDR

if False:
    def w_mvdr_uca(theta, r):
        to_r = 1.0 / (np.sqrt(2.0) * np.sqrt(1.0 - np.cos(2.0 * np.pi / num_mics))) # convert UCA inter element spacing back to its radius
        x = mic_sep * to_r * np.cos(2 * np.pi / num_mics * np.arange(num_mics))
        y = -1 * mic_sep * to_r * np.sin(2 * np.pi / num_mics * np.arange(num_mics))
        s = np.exp(1j * 2 * np.pi * (x * np.cos(theta) + y * np.sin(theta))).reshape(-1, 1) # steering vector in the desired direction theta
        s = s.reshape(-1,1) # make into a column vector (size 3x1)

        R = r @ r.conj().T # Calc covariance matrix. gives a Nr x Nr covariance matrix of the samples
        Rinv = np.linalg.pinv(R) # 3x3. pseudo-inverse tends to work better/faster than a true inverse

        w = (Rinv @ s)/(s.conj().T @ Rinv @ s) # MVDR/Capon equation! numerator is 3x3 * 3x1, denominator is 1x3 * 3x3 * 3x1, resulting in a 3x1 weights vector

        return w

    theta_scan = np.linspace(-1*np.pi, np.pi, 1000) # 1000 different thetas between -180 and +180 degrees
    results = []

    for theta_i in theta_scan:
        w = w_mvdr_uca(theta_i, r) # 3x1
        r_weighted = w.conj().T @ r # apply weights
        power_dB = 10*np.log10(np.var(r_weighted)) # power in signal, in dB so its easier to see small and large lobes at the same time
        results.append(power_dB)

    results -= np.max(results) # normalize


    fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
    ax.plot(theta_scan, results) # MAKE SURE TO USE RADIAN FOR POLAR
    ax.set_theta_zero_location('N') # make 0 degrees point up
    ax.set_theta_direction(-1) # increase clockwise
    ax.set_rlabel_position(55)  # Move grid labels away from other labels
    ax.set_ylim([-10, 0]) # only plot down to -40 dB
    plt.show()

    exit()


# PERFORM DOA LOCALISATION WITH MUSIC

if True:
    num_expected_signals = 1


    # part that doesn't change with theta_i
    R = r @ r.conj().T # Calc covariance matrix, it's Nr x Nr
    w, v = np.linalg.eig(R) # eigenvalue decomposition, v[:,i] is the eigenvector corresponding to the eigenvalue w[i]

    eig_val_order = np.argsort(np.abs(w)) # find order of magnitude of eigenvalues
    v = v[:, eig_val_order] # sort eigenvectors using this order

    # We make a new eigenvector matrix representing the "noise subspace", it's just the rest of the eigenvalues

    V = np.zeros((num_mics, num_mics - num_expected_signals), dtype=np.complex64)

    for i in range(num_mics - num_expected_signals):
        V[:, i] = v[:, i]


    theta_scan = np.linspace(-1*np.pi, np.pi, 1000) # 1000 different thetas between -180 and +180 degrees
    results = []

    for theta_i in theta_scan:
        to_r = 1.0 / (np.sqrt(2.0) * np.sqrt(1.0 - np.cos(2.0 * np.pi / num_mics))) # convert UCA inter element spacing back to its radius
        x = mic_sep * to_r * np.cos(2 * np.pi / num_mics * np.arange(num_mics))
        y = -1 * mic_sep * to_r * np.sin(2 * np.pi / num_mics * np.arange(num_mics))

        s = np.exp(1j * 2 * np.pi * (x * np.cos(theta_i) + y * np.sin(theta_i))).reshape(-1, 1) # steering vector in the desired direction theta
        s = s.reshape(-1,1) # make into a column vector (size 3x1)

        metric = 1 / (s.conj().T @ V @ V.conj().T @ s) # The main MUSIC equation
        metric = np.abs(metric.squeeze()) # take magnitude
        metric = 10*np.log10(metric) # convert to dB
        results.append(metric)

    results -= np.max(results) # normalize


    fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
    ax.plot(theta_scan, results) # MAKE SURE TO USE RADIAN FOR POLAR
    ax.set_theta_zero_location('N') # make 0 degrees point up
    ax.set_theta_direction(-1) # increase clockwise
    ax.set_rlabel_position(55)  # Move grid labels away from other labels

    #ax.set_ylim([-10, 0]) # only plot down to -40 dB

    plt.show()

    exit()
