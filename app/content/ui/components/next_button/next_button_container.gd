extends Node3D

func updatenextstationdata(nextstation):
	if nextstation:
		$NextButton.label = nextstation["icon"]
		$NextButton.disabled = (nextstation["station"] == null)
		$NextLabel.text = nextstation["label"]
		visible = true
	else:
		visible = false
		$NextButton.disabled = true

func setpreviewtrail(nss):
	if nss and nss.get("station"):
		var frompt = $NextButton.global_position
		var topt = nss["station"].global_position
		$NextPreviewTrail.look_at_from_position((frompt + topt)*0.5, topt)
		$NextPreviewTrail.scale.z = (frompt - topt).length()
		$NextPreviewTrail.visible = true
	else:
		$NextPreviewTrail.visible = false
