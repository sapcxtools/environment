function yUpdateArtefacts {
	# Update Commerce Suite Artefacts
	cd "$CXDEVHOME/dependencies/commercesuite"
	_yRelinkArtefacts
	
	# Update Integration Pack Artefacts
	cd "$CXDEVHOME/dependencies/integrationpack"
	_yRelinkArtefacts
}

function _yRelinkArtefacts {
	# Relink SAP Artefacts with correct versions
	find . -maxdepth 1 -type l | xargs rm -f
	for i in $(ls -A); do
		if [[ $i =~ ^.*\.(zip|ZIP) ]]; then
			ln -s $i $(echo $i | sed -E 's/([A-Z]+)([0-9]{4}).*_([0-9]{1,3})-.*(ZIP|zip)/\1-\2.\3.zip/g')
		fi
	done
}
