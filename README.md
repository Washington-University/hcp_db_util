Client utilities for the Human Connectome Project ConnectomeDB
============================================================

hcp_dcm_dump: display DICOM metadata from archived files
--------------------------------------------------------

Usage: hcp_dcm_dump -u USER -s SESSION-ID [-p PROJECT-ID]
                      [-r SCAN-ID] [-f FIELD]...'

With no field arguments, displays all DICOM metadata for one file
chosen arbitrarily from the specified session. If a scan is specified,
the file is chosen from that scan. If no project is specified, the
session is assumed to be in HCP_Phase2.

If field arguments are provided, only those fields are displayed.


Questions? Contact Kevin A. Archie <karchie@wustl.edu>
