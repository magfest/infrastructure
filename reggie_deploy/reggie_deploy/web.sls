# ============================================================================
# Delete nginx cache if there are code updates
# ============================================================================

delete nginx cache:
  cmd.run:
    - name: 'find /var/cache/nginx/**/* -type f | xargs rm --'
    - onlyif: 'find /var/cache/nginx/**/* -type f 2> /dev/null | grep -q /var/cache/nginx/'
    - onchanges:
      - sls: reggie.install


nginx maintenance page:
{% if salt['pillar.get']('reggie:maintenance') %}
  file.managed:
    - name: /var/www/maintenance.html
    - contents: |
        <!DOCTYPE html>
        <html>
          <head>
            <title>MAGFest Maintenance</title>
            <style>
              html, body {
                font-family: Helvetica, Arial, sans-serif;
                text-align: center;
              }
              div {
                margin: 0 auto;
                max-width: 640px;
                text-align: left;
                width: 100%;
              }
              pre {
                display: inline-block;
                margin: 0;
                font-family: monospace;
                font-size: 1.5em;
                font-weight: bold;
                text-align: left;
                white-space: pre;
              }
            </style>
          </head>
          <body>
            <h1>MAGFest Registration Maintenance Mode</h1>
            <div>
              MAGBot is working at 110% to get everything running again... <em>*beep* *boop*</em>
              <br><br>
              Sorry about that, we'll be back in a few. Hang tight!
              <br><br>
              Here's a donut while you wait:
            </div>
            <pre>
           _.-------._
         .' . '___ `  '.
        /` ' ,(___) . ` \
        |'._    . `  _.'|
        |   `'-----'`   |
         \             /
          '-.______..-'
            </pre>
          </body>
        </html>

{% else %}
  file.absent:
    - name: /var/www/maintenance.html
{% endif %}
