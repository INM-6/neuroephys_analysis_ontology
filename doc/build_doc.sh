#!/bin/bash
set -e

log_message () {
	printf "\n\n[$(date)] $1\n\n"
}


insert_html () {
	DEST_FILE=$1/index-en.html
	DOC_FILES=$2
	log_message "Inserting custom HTML text in '$DOC_FILES' into '$DEST_FILE'"
	gawk -i inplace -v r="$(cat $DOC_FILES/introduction.html)" '{gsub(/introduction.html/,r)}1' $DEST_FILE
	gawk -i inplace -v r="$(cat $DOC_FILES/description.html)" '{gsub(/description.html/,r)}1' $DEST_FILE 
    gawk -i inplace -v RS='{ "is multiline" }' -v r="<span class=\"markdown\">$(cat $DOC_SRC_FOLDER/acknowledgements.html)</span>" '{gsub(/(<p>\nThe authors would like to thank.*documentation\.<\/p>)/,r)}1' $DEST_FILE
}


clean_section () {
	DEST_FILE=$1/index-en.html
	log_message "Cleaning '$2' from '$DEST_FILE'"
	CONDITION="div[@id=\"$2\"]"
	xml_grep --html --exclude "$CONDITION" $DEST_FILE > $DEST_FILE.tmp
	mv $DEST_FILE.tmp $DEST_FILE
}


clean_annotation () {
	DEST_FILE=$1
	log_message "Cleaning information for annotation property '$2' from '$DEST_FILE'"

	# List headers
	CONDITION="a[@title=\"$2\"]"
	xml_grep --html --exclude "$CONDITION" $DEST_FILE > $DEST_FILE.tmp
	mv $DEST_FILE.tmp $DEST_FILE

	# Property panel
	CONDITION="div[@id=\"$2\"]"
	xml_grep --html --root 'div[@id="annotationproperties"]' --exclude "$CONDITION" $DEST_FILE > $DEST_FILE.tmp
	mv $DEST_FILE.tmp $DEST_FILE
}

clean_annotation_properties () {
	DEST_FILE=$1/index-en.html
	echo "Cleaning annotation_properties from '$DEST_FILE'"
	clean_annotation "$DEST_FILE" "http://purl.org/dc/terms/creator"
	clean_annotation "$DEST_FILE" "http://purl.org/dc/terms/created"
	clean_annotation "$DEST_FILE" "http://purl.org/dc/terms/license"
	clean_annotation "$DEST_FILE" "http://www.w3.org/2004/02/skos/core#prefLabel"
	clean_annotation "$DEST_FILE" "http://purl.org/vocab/vann/preferredNamespacePrefix"
	clean_annotation "$DEST_FILE" "http://purl.org/vocab/vann/preferredNamespaceUri"
	gawk --i inplace -v RS='{ "is multiline" }' -v r="" '{gsub(/(<li>\n\s+\n\s+<\/li>)/,r)}1' $DEST_FILE
}


rename_files () {
	BASE_FOLDER=$1
	mv $BASE_FOLDER/index-en.html $BASE_FOLDER/index.html
	mv $BASE_FOLDER/ontology.ttl $BASE_FOLDER/$2.ttl
	mv $BASE_FOLDER/ontology.nt $BASE_FOLDER/$2.nt
	mv $BASE_FOLDER/ontology.owl $BASE_FOLDER/$2.xml
	mv $BASE_FOLDER/ontology.jsonld $BASE_FOLDER/$2.jsonld
}

remove_files () {
	BASE_FOLDER=$1
	rm $BASE_FOLDER/$2.ttl
	rm $BASE_FOLDER/$2.nt
	rm $BASE_FOLDER/$2.xml
	rm $BASE_FOLDER/$2.jsonld
}
	
# This script requires xml_grep
if ! command -v xml_grep &> /dev/null
then
	printf "\nxml_grep is needed. Please install it using your package manager (e.g., 'apt install xml-twig-tools').\n\n"
	exit
fi

# This script requires ROBOT
if ! command -v robot &> /dev/null
then
	printf "\nROBOT is needed. Please install it from 'https://robot.obolibrary.org'.\n\n"
	exit
fi

# Get release version from command line
CURRENT_RELEASE=$1
if [ -z "$CURRENT_RELEASE" ]
then
	printf "\nProvide the current release version to identify which documentation will be built.\n"
	printf "The files of the requested release will be built and stored in './releases/<version>'.\n\n"
	exit
fi

# Get WIDOCO JAR path. It can be passed by command line as the second argument
# Otherwise it is assumed to be stored in ~/opt/widoco/widoco.jar
WIDOCO_JAR=$2
if [ -z "$WIDOCO_JAR" ]
then
  WIDOCO_JAR="$HOME/opt/widoco/widoco.jar"
fi

# Check if WIDOCO is working
if ! java -jar $WIDOCO_JAR --version
then
   printf "\nWIDOCO JAR file '$WIDOCO_JAR' not found or does not run.\n\n"
   printf "1. Please, provide the path to the JAR file via the CLI:\n\n"
   printf "   build_doc.sh <build version> <path to widoco jar>\n\n"
   printf "2. Check that Java is configured correctly.\n\n"
   exit
fi

# Create release folder if needed
mkdir -p ./releases

# Define folders
DOC_FOLDER=$(realpath ./releases/$CURRENT_RELEASE)
SRC_FOLDER=$(realpath ../src)
DOC_SRC_FOLDER=$(realpath ./source)
log_message "Using NEAO sources in '$SRC_FOLDER'"
log_message "Using documentation configuration and source files in '$DOC_SRC_FOLDER'"

# Clean current build
log_message "Cleaning any previous build in '$DOC_FOLDER'"
rm -rf $DOC_FOLDER
mkdir -p $DOC_FOLDER

NEAO_MERGED_SRC=$SRC_FOLDER/neao_merge.owl
rm -f $NEAO_MERGED_SRC

# Build merged source with ROBOT
log_message "Generating merged OWL source"
robot --input $SRC_FOLDER/neao.owl --output $NEAO_MERGED_SRC

# Run WIDOCO to build the documentation
# A WIDOCO run is done for each module
# The HTML output can be post-processed to tweak the visualization

# Main page
log_message "Building main documentation page"
java -jar $WIDOCO_JAR -ontFile $NEAO_MERGED_SRC -outFolder $DOC_FOLDER -uniteSections -rewriteAll -confFile $DOC_SRC_FOLDER/config.properties
clean_section "$DOC_FOLDER" "abstract"
clean_section "$DOC_FOLDER" "namespacedeclarations"
clean_section "$DOC_FOLDER" "overview"
clean_section "$DOC_FOLDER" "crossref"
clean_section "$DOC_FOLDER" "references"
insert_html "$DOC_FOLDER" "$DOC_SRC_FOLDER"
rename_files "$DOC_FOLDER" "neao"


# Base module
log_message "Building base module documentation"
java -jar $WIDOCO_JAR -ontFile $SRC_FOLDER/base/base.owl -outFolder $DOC_FOLDER/base -webVowl -uniteSections -rewriteAll -includeAnnotationProperties -doNotDisplaySerializations -confFile $DOC_SRC_FOLDER/base/config-base.properties
clean_section "$DOC_FOLDER/base" "abstract"
clean_section "$DOC_FOLDER/base" "references"
clean_annotation_properties "$DOC_FOLDER/base"
insert_html "$DOC_FOLDER/base" "$DOC_SRC_FOLDER/base"
rename_files "$DOC_FOLDER/base" "base" 
remove_files "$DOC_FOLDER/base" "base" 


# Steps module
log_message "Building steps module documentation"
java -jar $WIDOCO_JAR -ontFile $SRC_FOLDER/steps/steps.owl -outFolder $DOC_FOLDER/steps -webVowl -uniteSections -rewriteAll -ignoreIndividuals -doNotDisplaySerializations -confFile $DOC_SRC_FOLDER/steps/config-steps.properties
clean_section "$DOC_FOLDER/steps" "abstract"
clean_section "$DOC_FOLDER/steps" "references"
insert_html "$DOC_FOLDER/steps" "$DOC_SRC_FOLDER/steps"
rename_files "$DOC_FOLDER/steps" "steps" 
remove_files "$DOC_FOLDER/steps" "steps" 


# Data module
log_message "Building data module documentation"
java -jar $WIDOCO_JAR -ontFile $SRC_FOLDER/data/data.owl -outFolder $DOC_FOLDER/data -webVowl -uniteSections -rewriteAll -ignoreIndividuals -doNotDisplaySerializations -confFile $DOC_SRC_FOLDER/data/config-data.properties
clean_section "$DOC_FOLDER/data" "abstract"
clean_section "$DOC_FOLDER/data" "references"
insert_html "$DOC_FOLDER/data" "$DOC_SRC_FOLDER/data"
rename_files "$DOC_FOLDER/data" "data" 
remove_files "$DOC_FOLDER/data" "data" 


# Parameters module
log_message "Building parameters module documentation"
java -jar $WIDOCO_JAR -ontFile $SRC_FOLDER/parameters/parameters.owl -outFolder $DOC_FOLDER/parameters -webVowl -uniteSections -ignoreIndividuals -rewriteAll -doNotDisplaySerializations -confFile $DOC_SRC_FOLDER/parameters/config-parameters.properties
clean_section "$DOC_FOLDER/parameters" "abstract"
clean_section "$DOC_FOLDER/parameters" "references"
insert_html "$DOC_FOLDER/parameters" "$DOC_SRC_FOLDER/parameters"
rename_files "$DOC_FOLDER/parameters" "parameters" 
remove_files "$DOC_FOLDER/parameters" "parameters" 


# Bibliography module
log_message "Building bibliography module documentation"
java -jar $WIDOCO_JAR -ontFile $SRC_FOLDER/bibliography/bibliography.owl -outFolder $DOC_FOLDER/bibliography -uniteSections -rewriteAll -doNotDisplaySerializations -confFile $DOC_SRC_FOLDER/bibliography/config-bibliography.properties
clean_section "$DOC_FOLDER/bibliography" "abstract"
clean_section "$DOC_FOLDER/bibliography" "references"
insert_html "$DOC_FOLDER/bibliography" "$DOC_SRC_FOLDER/bibliography"
rename_files "$DOC_FOLDER/bibliography" "bibliography"
remove_files "$DOC_FOLDER/bibliography" "bibliography" 


# Copy images
log_message "Copying images"
cp -r $DOC_SRC_FOLDER/images $DOC_FOLDER/images


# Cleanup
log_message "Removing temporary files"
rm -rf ./tmp*

log_message "Documentation for $CURRENT_RELEASE built!"
