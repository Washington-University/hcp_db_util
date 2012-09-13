Client utilities for the Human Connectome Project ConnectomeDB
--------------------------------------------------------------

_ _ _

### hcp\_dcm\_dump: display DICOM metadata from archived files

Displays DICOM metadata for one file in the named session, in a format
similar to the DCMTK utility dcmdump.

#### Usage

<code>
hcp\_dcm\_dump -u USER[:PASSWORD] -s SESSION-ID [-p PROJECT-ID] [-r SCAN-ID] [-f FIELD]...
</code>

#### Description

With no field arguments, displays all DICOM metadata for one file
selected arbitrarily from the specified session. If a scan is
specified, the file is chosen from that scan. If no project is
specified, the project is assumed to be <code>HCP_Phase2</code>.

If field arguments are provided, only the specified fields are
displayed. Fields may be specified as 8-hex-digit numeric tags or by
name:

<code>
hcp\_dcm\_dump -u hcpuser -s 001_strc -f 00080020 -f SeriesNumber
</code>

 Fields in Siemens shadow headers may be specified as _shadow-header-tag_:_field-name_ :

<code>
hcp\_dcm\_dump -u hcpuser -s 001_strc -f 00291020:GradientMode
</code>

#### BUGS

The output for the Siemens MR Phoenix Protocol is a big mess.

_ _ _

Questions? Contact Kevin A. Archie <karchie@wustl.edu>
