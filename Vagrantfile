vm_box_name = ["Server", "Client"]
vm_name = "Ubuntu 22.04.1 LTS"
vm_host_name = "ubuntu2204"
nicname = ["Intel", "VirtIO"]
iperf3dir="/home/vagrant/iperf3/"
ip="192.168.56."

Vagrant.configure("2") do | config |
	(0..1).each do | nictype |
		(0..1).each do | sc |
			config.vm.define vm_box_name[sc] + "-" + nicname[nictype] do | node |
				node.vm.box = "ubuntu/jammy64"
				node.vm.box_check_update = false
				node.vm.hostname = "#{vm_box_name[sc]}#{vm_host_name}".downcase
				node.vm.synced_folder ".", "/vagrant", disabled: true
				
				if sc == 1 
					node.vm.synced_folder ".", iperf3dir, owner: "vagrant", group: "vagrant"
				end
				
				if nictype == 0
					node.vm.network "private_network", ip: ip + ((nictype+1) * 10 + sc).to_s
				else
					node.vm.network "private_network", ip: ip + ((nictype+1) * 10 + sc).to_s, nic_type: "virtio"
				end
				
				node.vm.provider "virtualbox" do | vb | 
					vb.name = "#{vm_name} #{vm_box_name[sc]} #{nicname[nictype]}"
					vb.check_guest_additions = false
					vb.memory = 2048
				end

				node.vm.provision "shell", name: "Startup", keep_color: true, inline: <<-SCRIPT
					#/usr/local/bin/env bash
					iperf3dir="#{iperf3dir}"
					
					title=("Private Network Intel Nic" "Private Network VirtIO Nic")

					if [ "#{sc}" == "0" ]; then
						if [ ! -f updateinstallflag#{sc}#{nictype} ]; then
							echo "Updating local repo directory"
							apt -y update

							echo "Installing iperf3"
							apt -y install iperf3

							touch updateinstallflag#{sc}#{nictype}

							echo "Starting iperf3 in background"
							(iperf3 -s -1 && systemctl poweroff) &
							exit 0
						else
							echo "Starting iperf3 in background"
							(iperf3 -s -1 && systemctl poweroff) &
							exit 0
						fi
					else
						if [ ! -f updateinstallflag#{sc}#{nictype} ]; then
							echo "Updating local repo directory"
							apt -y update

							if [[ "#{sc}" == "1" && "#{nictype}" == "1" ]]; then
								touch updateinstallflag#{sc}#{nictype}
								
								echo "Installing iperf3 chromium-browser jq"
								apt -y install iperf3 chromium-browser jq

								echo "Installing marp-cli"
								curl -s -O -L https://github.com/marp-team/marp-cli/releases/download/v2.3.0/marp-cli-v2.3.0-linux.tar.gz
								tar -xf marp-cli-v2.3.0-linux.tar.gz
							else
								touch updateinstallflag#{sc}#{nictype}
								echo "Installing iperf3 jq"
								apt -y install iperf3 jq
							fi
						fi

						ping -c 4 #{ip + ((nictype + 1)*10).to_s}

						echo "Doing iperf3 to ${title[#{nictype}]}, wait a little bit"
						iperf3 -c #{ip + ((nictype + 1)*10).to_s} --json --logfile ${iperf3dir}output#{nictype}.json

						if [[ "#{sc}" == "1" && "#{nictype}" == "0" ]]; then
							echo "---" > ${iperf3dir}output.md
							echo "title: Emulated nic vs virtio" >> ${iperf3dir}output.md
							echo "description: VirtualBox Hypervisor" >> ${iperf3dir}output.md
							echo "paginate: true" >> ${iperf3dir}output.md
							echo "marp: true" >> ${iperf3dir}output.md
							echo "theme: uncover" >> ${iperf3dir}output.md
							echo "---" >> ${iperf3dir}output.md
							echo "![bg](https://picsum.photos/720)" >> ${iperf3dir}output.md
							echo "<!-- _class: invert -->" >> ${iperf3dir}output.md
							echo "# Emulated nic vs virtio" >> ${iperf3dir}output.md
							echo "## <span style='color:orange;'>$(date +"%Y-%m-%d")</span><!-- fit -->" >> ${iperf3dir}output.md
							echo "## <span style='color:black;'>Let's see who's the winner is</span><!-- fit -->" >> ${iperf3dir}output.md
						fi
						
						echo "" >> ${iperf3dir}output.md
						echo "---" >> ${iperf3dir}output.md
						echo "<!-- _class: invert -->" >> ${iperf3dir}output.md
						echo "${title[#{nictype}]}" >> ${iperf3dir}output.md
						echo "* IP" >> ${iperf3dir}output.md
						echo "    * Local: $(jq -r '.start.connected[].local_host' ${iperf3dir}output#{nictype}.json)" >> ${iperf3dir}output.md
						echo "    * Remote: $(jq -r ".start.connected[].remote_host" ${iperf3dir}output#{nictype}.json)" >> ${iperf3dir}output.md
						echo "* Bits/s" >> ${iperf3dir}output.md
						echo "    * Sum sent: $(jq -r '.end.sum_sent.bits_per_second' ${iperf3dir}output#{nictype}.json | LC_ALL=C numfmt --to=iec-i)" >> ${iperf3dir}output.md
						echo "    * Sum received: $(jq -r '.end.sum_received.bits_per_second' ${iperf3dir}output#{nictype}.json | LC_ALL=C numfmt --to=iec-i)" >> ${iperf3dir}output.md
						echo "* Bytes" >> ${iperf3dir}output.md
						echo "    * Sum sent: $(jq -r '.end.sum_sent.bytes' ${iperf3dir}output#{nictype}.json | LC_ALL=C numfmt --to=iec-i)" >> ${iperf3dir}output.md
						echo "    * Sum received: $(jq -r '.end.sum_received.bytes' ${iperf3dir}output#{nictype}.json | LC_ALL=C numfmt --to=iec-i)" >> ${iperf3dir}output.md
					
						if [[ "#{sc}" == "1" && "#{nictype}" == "1" ]]; then
							echo "---" >> ${iperf3dir}output.md
							echo "<!-- _class: invert -->" >> ${iperf3dir}output.md
							echo "# Thanks!" >> ${iperf3dir}output.md
							echo "* Joel" >> ${iperf3dir}output.md
							echo "    * For making this comes true" >> ${iperf3dir}output.md
							echo "    * For letting us know to use this great tools" >> ${iperf3dir}output.md
							echo "* HashiCorp" >> ${iperf3dir}output.md
							echo "    * For using ruby as language to use when config Vagrant" >> ${iperf3dir}output.md
							su - vagrant -c "./marp --pdf --html -I ${iperf3dir} -o ${iperf3dir}"
						fi
						systemctl poweroff
					fi
				SCRIPT
			end
		end
	end
end