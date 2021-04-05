FROM archlinux
MAINTAINER Kamil Cukrowski <kamilcukrowski@gmail.com>

RUN set -x && \
	\
	# Setup yay with builder account for building stuff from AUR
	printf '%s\n' '[archlinuxcn]' 'SigLevel = Never' 'Server = http://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf && \
	pacman -Suy --noconfirm --needed base-devel yay sudo && \
	useradd builder --system --shell /sbin/nologin --home-dir /var/cache/build --create-home && \
	chmod +w /etc/sudoers && \
	printf '%s ALL=(ALL) NOPASSWD: ALL\n' 'builder' 'root' >> /etc/sudoers && \
	chmod -w /etc/sudoers && \
	\
	sudo -u builder yay -Suy --noconfirm --needed \
		recoll \
		# Stuff that recall might use.
		wv poppler \
		libxslt unzip poppler pstotext antiword catdoc unrtf djvulibre id3lib python-mutagen perl-image-exiftool python-lxml python-pychm \
		aspell-en aspell-de aspell-pl \
		libxslt untex perl-image-exiftool antiword pstotext \
		# Dependency for recoll-webui.
		python-waitress \
		# Stuff I use
		git supervisor \
		&& \
	git clone https://framagit.org/medoc92/recollwebui /recollwebui

EXPOSE 8080
COPY supervisord.conf /etc/supervisord.conf
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]

# Chagne this to the user you want to have.
RUN set -x && \
	groupadd -g 1200 share && \
	useradd -g 1200 -u 1200 --create-home share
USER 1200:1200

