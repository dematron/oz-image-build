OZ_DEBUG=3
.SUFFIXES = .tdl

# (1) Add new targets here
CENTOS = centos60_x86_64
SCIENTIFIC6 = sl63_x86_64
FEDORA15 = fedora15_x86_64
FEDORA16 = fedora16_x86_64
RHEL5 = rhel56_x86_64
RHEL6 = rhel61_x86_64 rhel62_x86_64
LUCID = ubuntu-lucid_x86_64_60G ubuntu-lucid_x86_64_80G \
		ubuntu-lucid_x86_64_120G ubuntu-lucid_x86_64_160G \
		ubuntu-lucid_x86_64_320G
MAVERICK = ubuntu-maverick_x86_64_60G ubuntu-maverick_x86_64_80G \
		ubuntu-maverick_x86_64_120G ubuntu-maverick_x86_64_160G \
		ubuntu-maverick_x86_64_320G
NATTY = ubuntu-natty_x86_64_60G ubuntu-natty_x86_64_80G \
		ubuntu-natty_x86_64_120G ubuntu-natty_x86_64_160G \
		ubuntu-natty_x86_64_320G
ONEIRIC = ubuntu-oneiric_x86_64_60G ubuntu-oneiric_x86_64_80G \
		ubuntu-oneiric_x86_64_120G ubuntu-oneiric_x86_64_160G \
		ubuntu-oneiric_x86_64_320G
PRECISE = ubuntu-precise_x86_64_60G ubuntu-precise_x86_64_80G \
		ubuntu-precise_x86_64_120G ubuntu-precise_x86_64_160G \
		ubuntu-precise_x86_64_320G
TARGETS = $(FEDORA15) $(FEDORA16) $(CENTOS) $(SCIENTIFIC6) $(RHEL5) $(RHEL6) \
		$(LUCID) $(MAVERICK) $(NATTY) $(ONEIRIC) $(PRECISE)

# (2) Add a global buil command for the target
all:		$(TARGETS)
fedora15:	$(FEDORA15)
fedora16:	$(FEDORA16)
centos:		$(CENTOS)
scientific6:	$(SCIENTIFIC6)
rhel5:		$(RHEL5)
rhel6:		$(RHEL6)
lucid:		$(LUCID)
maverick:	$(MAVERICK)
natty:		$(NATTY)
oneiric:	$(ONEIRIC)
precise:	$(PRECISE)

# (3) Add specific upload and clean rules for the target
centos-upload:	$(CENTOS)
	@$(foreach var,$(CENTOS),make publish/$(var)-upload;)
centos-clean:
	@$(foreach var,$(CENTOS),make $(var)-clean;)

scientific6-upload:   $(SCIENTIFIC6)
	@$(foreach var,$(SCIENTIFIC6),make publish/$(var)-upload;)
scientific6-clean:
	@$(foreach var,$(SCIENTIFIC6),make $(var)-clean;)

fedora-upload:
	@make fedora15-upload
	@make fedora15-upload

fedora15-upload:	$(FEDORA15)
	@$(foreach var,$(FEDORA15),make publish/$(var)-upload;)
fedora15-clean:
	@$(foreach var,$(FEDORA15),make $(var)-clean;)

fedora16-upload:	$(FEDORA16)
	@$(foreach var,$(FEDORA16),make publish/$(var)-upload;)
fedora16-clean:
	@$(foreach var,$(FEDORA16),make $(var)-clean;)

rhel5-upload:	$(RHEL5)
	@$(foreach var,$(RHEL5),make publish/$(var)-upload;)
rhel5-clean:
	@$(foreach var,$(RHEL5),make $(var)-clean;)

rhel6-upload:	$(RHEL6)
	@$(foreach var,$(RHEL6),make publish/$(var)-upload;)
rhel6-clean:
	@$(foreach var,$(RHEL6),make $(var)-clean;)

lucid-upload:	$(LUCID)
	@$(foreach var,$(LUCID),make publish/$(var)-upload;)
lucid-clean:
	@$(foreach var,$(LUCID),make $(var)-clean;)

maverick-upload:	$(MAVERICK)
	@$(foreach var,$(MAVERICK),make publish/$(var)-upload;)
maverick-clean:
	@$(foreach var,$(MAVERICK),make $(var)-clean;)

natty-upload:	$(NATTY)
	@$(foreach var,$(NATTY),make publish/$(var)-upload;)
natty-clean:
	@$(foreach var,$(NATTY),make $(var)-clean;)

oneiric-upload:	$(ONEIRIC)
	@$(foreach var,$(ONEIRIC),make publish/$(var)-upload;)
oneiric-clean:
	@$(foreach var,$(ONEIRIC),make $(var)-clean;)

precise-upload:	$(PRECISE)
	@$(foreach var,$(PRECISE),make publish/$(var)-upload;)
precise-clean:
	@$(foreach var,$(PRECISE),make $(var)-clean;)

#####
# DON'T CHANGE ANYTHING ELSE
#

$(TARGETS):
	make publish/$@.qcow2

templates/.%.tdl:	templates/%.tdl
	./fixup-root-passwords.sh templates/$*.tdl > templates/.$*.tdl

publish/%.qcow2: templates/%.tdl
	@echo "-- Building $*"
	make templates/.$*.tdl
	OZ_DEBUG=$(OZ_DEBUG) ./build-helper.sh .$* "$*.qcow2" "$*.dsk"

%-upload:
	make publish/$*-upload

publish/%-upload: publish/%.qcow2
	@echo "-- UPLOAD $*"
	./push.sh put publish/$*.qcow2 "RCB OPS" $*.qcow2
	touch $@

upload:	$(TARGETS)
	$(foreach var,$(TARGETS),make publish/$(var)-upload;)

%-clean:
	rm -f publish/$*.qcow2
	rm -f publish/$*-upload
	rm -f templates/.$*.tdl
	rm -f templates/.$*.xml

clean:
	find publish -type f -exec rm -f \{\} \;

fixup-passwords:
	$(foreach var,$(TARGETS),make templates/.$(var).tdl;)
