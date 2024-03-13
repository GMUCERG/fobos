.. _openADC-label:

Open ADC Module
***************

The FOBOS3 shield includes an analog-to-digital converter (ADC) used to convert power measurements to digital traces.
This ADC is based on OpenADC and its parameters are listed below.

+------------------------+---------------+
| Paramter               | Value         |
+========================+===============+
| bandwidth              | 40MHz         |
+------------------------+---------------+
| resolution             | 10 bits       |
+------------------------+---------------+
| maximum trace size     | 128 K samples |
+------------------------+---------------+


The ADC reads power measurement from the **measurement** SMA input on the FOBOS3 shield. The maximum trace length is 128 K samples in the current version.
A **trigger** pin is also provided to signal to the ADC when to start capturing the trace.
Once the ADC is armed, it waits for the positive edge of the trigger signal. Once the edge is detected,
the ADC starts to store the **samples_per_trace** samples which are transfered to the PYNQ board's memory.

A pre-amplifier is used to amplify the measured signal at the input of the ADC.
This pre-amplifier has a configurable gain that ranges from 0-60 which can be set from software.
The ADC gain can also has a configurable high/low setting.


Usage example and API
---------------------

API methods:

+------------------------------------------------+----------------------------------------------------------------------+
| Method                                         | Description                                                          |
+================================================+======================================================================+
| ctrl.setSamplingFrequency(SAMPLING_FRQUENCY)   | Sampling frequency range is 1-100 MHz                                |
+------------------------------------------------+----------------------------------------------------------------------+
| ctrl.setADCGain(ADC_GAIN)                      | ADC gain range is 0-60                                               |
+------------------------------------------------+----------------------------------------------------------------------+
| ctrl.setADCHiLo(ADC_HILO)                      | Sets high or low gain. Can be 0 or 1                                 |
+------------------------------------------------+----------------------------------------------------------------------+
| ctrl.setSamplesPerTrace(SAMPLES_PER_TRACE)     | Samples collected after trigger. 4 - 128 K. Must be a multiple of 4  |
+------------------------+-----------------------+----------------------------------------------------------------------+


Example:

The example below shows basic usage of the ADC to collect a set of traces.

.. code-block:: python

    import foboslib as fb
    from foboslib.capture.ctrl.pynqctrl import PYNQCtrl
    from foboslib.common.projmgr import ProjectManager
    
    # Initialize DUT, IO files here ++

    # ++++++++++++++++++++++++++++++++


    NUM_TRACES         = 100                   # number of traces to collect
    
    #Acquistion/scope configuration
    SAMPLING_FRQUENCY  = 50                    # sampling frequency of the Oscilloscope in Msps [default: 50][range: 1 - 100]
    SAMPLES_PER_TRACE  = 1000                  # number of sample in one trace [range: 1 - 2^17]
    ADC_GAIN           = 60                    # amplification of ADC input signal [default: 40][range: 0 - 60]
    ADC_HILO           = 1

    ctrl = PYNQCtrl(<IP>, <PORT>)              # connect to control board

    # configure DUT, trigger etc here
    
    # ADC settings
    ctrl.setSamplingFrequency(SAMPLING_FRQUENCY)
    ctrl.setADCGain(ADC_GAIN)
    ctrl.setADCHiLo(ADC_HILO)
    ctrl.setSamplesPerTrace(SAMPLES_PER_TRACE)

    # Trace collection
    for i in range(NUM_TRACES):
        data = tvFile.readline()
        status, result, trace = ctrl.processData2(data)
        cipherFile.write(result + "\n")
        np.save(traceFile, trace)
    print('Data acquisition complete.')
