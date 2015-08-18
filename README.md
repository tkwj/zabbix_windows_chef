# .-cookbook

Zabbix agent for Windows

## Supported Platforms

Windows 2008
Windows 2012

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['.']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### .::default

Include `.` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[.::default]"
  ]
}
```

## License and Authors

Author:: Thomas Vincent (thomasvincent@gmail.com)
