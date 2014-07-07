MSD analyzer
============

Mean square displacement (MSD) analysis is a technique commonly used in
colloidal studies and biophysics to determine what is the mode of displacement
of particles followed over time. In particular, it can help determine whether
the particle is:

* freely diffusing;
* transported;
* bound and limited in its movement.

On top of this, it can also derive an estimate of the parameters of the
movement, such as the diffusion coefficient.

@msdanalyzer is a MATLAB per-value class that helps performing this kind of
analysis. The user provides several trajectories he measured, and the class can
derive meaningful quantities for the determination of the movement modality,
assuming that all particles follow the same movement model and sample the same
environment.


