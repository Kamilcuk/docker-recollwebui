FROM archlinux
MAINTAINER Kamil Cukrowski <kamilcukrowski@gmail.com>


# https://hub.docker.com/repository/registry-1.docker.io/kamilcuk/docker-recollwebui/builds/24a44916-be3c-4a2e-86d2-d386ca00cb82
# https://www.reddit.com/r/archlinux/comments/lek2ba/arch_linux_on_docker_ci_could_not_find_or_read/
# https://github.com/qutebrowser/qutebrowser/commit/478e4de7bd1f26bebdcdc166d5369b2b5142c3e2
# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"


RUN set -x && \
	pacman -Suy --noconfirm --needed \
		recoll \
		# Stuff that recall might use.
		wv poppler \
		libxslt unzip poppler pstotext antiword catdoc unrtf djvulibre id3lib python-mutagen perl-image-exiftool python-lxml python-pychm \
		aspell-en aspell-de aspell-pl \
		libxslt perl-image-exiftool antiword pstotext \
		# Dependency for recoll-webui.
		python-waitress \
		# Stuff I use
		git supervisor \
		&& \
	git clone https://framagit.org/medoc92/recollwebui /recollwebui && \
	# Cleanup
	bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
	rm -fr /var/lib/pacman/sync/* /usr/share/info/* /usr/share/man/* /usr/share/doc/* /tmp/*

EXPOSE 8080
COPY supervisord.conf /etc/supervisord.conf
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]

# Chagne this to the user you want to have.
RUN set -x && \
	groupadd -g 1200 share && \
	useradd -g 1200 -u 1200 --create-home share
USER 1200:1200

