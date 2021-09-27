import gitlab

gl = gitlab.Gitlab(url="https://gitlab.com", private_token='qMm4P4GYds_ah6h-NBbt')

gl.auth()


project_name_with_namespace = "cacko/streamy"
project = gl.projects.get(project_name_with_namespace)

package = project.generic_packages.upload(
    package_name="wipy",
    package_version="v1.0.1",
    file_name="wipy.dmg",
    path="./wipy.dmg"
)

print(package)