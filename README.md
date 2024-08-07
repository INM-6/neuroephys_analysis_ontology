# Neuroelectrophysiology Analysis Ontology (NEAO)

The NEAO is a collection of controlled vocabularies and concepts to describe the typical processes involved in the analysis of neural activity data acquired using electrophysiology techniques.

The goal of NEAO is to provide a common framework for annotating neuroelectrophysiology data analysis workflows. This will result in the unambiguous identification of the processes and data elements involved, and also extended semantic information that can be used to reason about the analyses.

The published ontology is accessible through the main namespace http://purl.org/neao. This repository contains the sources and centralizes the development efforts within the community.

For requests or additions to NEAO, please first open an issue in the [issue tracker](https://github.com/INM-6/neuroephys_analysis_ontology/issues).

## Table of contents

- [Code repository](#code-repository)
- [Acknowledgments](#acknowledgments)
- [License](#license)

## Code repository

### OWL sources

NEAO was developed using [Protégé 5.5](https://protege.stanford.edu/software.php).

The ontology source code (OWL serialized as Turtle) is organized into subfolders inside the `/src` folder:

- `base`: the top-level classes of the NEAO model that are imported by other modules. It defines the three main classes, the software implementation description, and all the related properties.
- `steps`: module to extend the **AnalysisStep** base class, in order to define the specific analysis steps and their semantic groupings.
- `data`: module to extend the **Data** base class, in order to define the specific data entities and their semantic groupings.
- `parameters`: module to extend the **AnalysisParameter** base class, in order to define the specific parameters and their semantic groupings.
- `bibliography`: module that defines individuals with the bibliographic references used to annotate **AnalysisStep** classes.

Each folder contains the `.owl` file with the source, and a XML catalog file that is used to perform local imports correctly when loading into Protégé. A top-level OWL file `neao.owl` is contained in `\src` and imports all the submodules to produce the final NEAO OWL source. This file should be edited only for the NEAO ontology metadata.

### Documentation

The documentation source is found in the `/doc` folder:

- The HTML pages are built using [WIDOCO](https://github.com/dgarijo/Widoco). NEAO is based on the JAR release, that must be downloaded to the local system ([available here](https://github.com/dgarijo/WIDOCO/releases/latest)). The recommended path is `~/opt/widoco/widoco.jar`. 
  
  For the documentation build, `xml_grep` from [xmltwig](https://github.com/mirod/xmltwig/tree/master) is needed to post-process the generated files. In Ubuntu or other Linux distributions, it can be installed using a package manager:
  
  `apt install xml-twig-tools`
  
  Also, as part of the documentation and release process, the code from all modules is merged into a single OWL source using [ROBOT](https://robot.obolibrary.org/). ROBOT must be installed and accessible in the shell, i.e., by runing the `robot` command ('Getting Started' instructions [here]([https://robot.obolibrary.org/](https://robot.obolibrary.org/))). The recommended path for the JAR file and shell script is `/usr/local/bin` (but you can also add the folder with ROBOT files to the `PATH`).
  
  The complete build is done by running the `build_doc.sh` bash script. The version must be passed as a script argument:
  
  `./build_doc.sh x.x.x`
  
  If the WIDOCO JAR is stored in a path other than `~/opt/widoco/widoco.jar` , it must be passed as a second argument:
  
  `./build_doc.sh x.x.x local/path/to/widoco.jar`

- The subfolder `/doc/source` contains the configuration files, images, and plain HTML files used with WIDOCO. The documentation sources are separated for each ontology submodule, as WIDOCO generates a separate documentation page for each. After the typical documentation page is built, the generated HTML files are edited  to remove sections that are not needed, and the custom HTML text (for the Introduction, Description, and Acknowledgement sections) is inserted. 

- The subfolder `/doc/releases` contains the built HTML documentation and final OWL code of each version of NEAO released. Each release is stored in a subfolder named after the version (as defined when calling the `build_doc.sh` script).

- To visualize the documentation after the build, the generated files can be inserted into an Apache Docker image (this is required for the [WebVOWL](http://vowl.visualdataweb.org/webvowl.html) visualizations). The Docker files are located in the `/doc/docker` subfolder. Docker must be available and running in your system ([instructions here](https://docs.docker.com/engine/install/)). 
  
  First, the image must be built with the `build.sh` bash script (that will take the latest documentation files in `/doc/releases`).
  
  After a successful build, the local server can be initialized by running the image with `run.sh`. Documentation will be accessible at [http://localhost:8080](http://localhost:8080).

## Acknowledgments

This work was performed as part of the [Helmholtz School for Data Science in Life, Earth and Energy (HDS-LEE)](https://hds-lee.de) and received funding from the Helmholtz Association of German Research Centres. This project has received funding from the European Union’s Horizon 2020 Framework Programme for Research and Innovation under Specific Grant Agreement No. 945539 (Human Brain Project SGA3), the European Union’s Horizon Europe Programme under the Specific Grant Agreement No. 101147319 ([EBRAINS](https://ebrains.eu) 2.0 Project), the Ministry of Culture and Science of the State of North Rhine-Westphalia, Germany (NRW-network "[iBehave](https://ibehave.nrw)", grant number: NW21-049), and the Joint Lab "Supercomputing and Modeling for the Human Brain."

## License

CC BY 4.0
