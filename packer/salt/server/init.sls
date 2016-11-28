pkg-epel-release:
  pkg.installed:
    - name: epel-release

pkg-nginx:
  pkg.installed:
    - name: nginx
    - require:
      - pkg: pkg-epel-release
  service.running:
    - name: nginx
    - enable: true
    - reload: true
    - require:
      - pkg: pkg-nginx

default-nginx-index:
  file.managed:
    - name: /usr/share/nginx/html/index.html
    - source: salt://server/files/usr/share/nginx/html/index.html
    - user: root
    - group: root
    - mode: 0644
