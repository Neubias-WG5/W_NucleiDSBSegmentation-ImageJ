// Author: Sébastien Tosi (IRB Barcelona)
// Use FIJI to run the macro with a command similar to
// java -Xmx6000m -cp jars/ij.jar ij.ImageJ -headless --console -macro IJSegmentClusteredNuclei.ijm "input=/inpath, output=/outpath, radiusgray=3, radiuscol=9, threshold=-0.025"

setBatchMode(true);

// Path to input image and output image (label mask)
inputDir = "/dockershare/666/in/";
outputDir = "/dockershare/666/out/";

// Functional parameters
LapRadgray = 3;
LapRadcol = 9;
LapThr = -0.025;

arg = getArgument();
parts = split(arg, ",");

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "radiusgray")>-1) LapRadgray=nameAndValue[1];
	if (indexOf(nameAndValue[0], "radiuscol")>-1) LapRadcol=nameAndValue[1];
	if (indexOf(nameAndValue[0], "threshold")>-1) LapThr=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		wait(100);
		
		// Processing
		// Assuming dominant background, check if below mid range
		run("8-bit");
		run("Set Measurements...", "  median redirect=None decimal=2");
		run("Select None");
		run("Clear Results");
		run("Measure");
		Med = getResult("Median",0);
		if(Med>127)
		{
			run("Invert");
			run("FeatureJ Laplacian", "compute smoothing="+d2s(LapRadcol,2));
			setThreshold(-1e15,LapThr);
			run("Convert to Mask");
			run("Fill Holes");
		}
		else
		{
			run("FeatureJ Laplacian", "compute smoothing="+d2s(LapRadgray,2));
			setThreshold(-1e15,LapThr);
			run("Convert to Mask");
			run("Fill Holes");
		}
		run("Analyze Particles...", "size=25-10000 circularity=0.3-1.00 show=[Count Masks] clear");
		
		// Export results
		save(outputDir + "/" + image);
		
		// Cleanup
		run("Close All");
	}
}
run("Quit");