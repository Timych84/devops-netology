1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.

Полный хеш:\
&nbsp;`aefead2207ef7e2aa5dc81a34aedf0cad4c32545`\
Комментарий:\
&nbsp;`Update CHANGELOG.md`

```
$ git  show -s  --format="%H,%s" aefea
aefead2207ef7e2aa5dc81a34aedf0cad4c32545,Update CHANGELOG.md
```
2. Какому тегу соответствует коммит `85024d3`?

Тег:\
`v0.12.23`
```
$ git show -s --oneline 85024d3
85024d3100 (tag: v0.12.23) v0.12.23
```

3. Сколько родителей у коммита `b8d720`? Напишите их хеши.

Родители коммита:\
`56cd7859e05c36c06b56d013b55a252d0bb7e158`\
`9ea88f22fc6269854151c571162c5bcf958bee2b`

```
$ git show b8d720 -s --format=%P
56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
```

4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.

| Hash        | Комментарий           |
|-|-|
|b14b74c493| [Website] vmc provider links|
|3f235065b9| Update CHANGELOG.md|
|6ae64e247b| registry: Fix panic when server is unreachable|
|5c619ca1ba| website: Remove links to the getting started guide's old location|
|06275647e2| Update CHANGELOG.md|
|d5f9411f51| command: Fix bug when using terraform login on Windows|
|4b6d06cc5d| Update CHANGELOG.md|
|dd01a35078| Update CHANGELOG.md|
|225466bc3e| Cleanup after v0.12.23 release|

```
$ git log v0.12.23..v0.12.24 --oneline
33ff1c03bb (tag: v0.12.24) v0.12.24
b14b74c493 [Website] vmc provider links
3f235065b9 Update CHANGELOG.md
6ae64e247b registry: Fix panic when server is unreachable
5c619ca1ba website: Remove links to the getting started guide's old location
06275647e2 Update CHANGELOG.md
d5f9411f51 command: Fix bug when using terraform login on Windows
4b6d06cc5d Update CHANGELOG.md
dd01a35078 Update CHANGELOG.md
225466bc3e Cleanup after v0.12.23 release
```

5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит 
так `func providerSource(...)` (вместо троеточего перечислены аргументы).

Хеш коммита:\
`8c928e83589d90a031f811fae52a81be7153e82f`

```
$ git grep -p 'func providerSource'
provider_source.go=import (
provider_source.go:func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
provider_source.go=func implicitProviderSource(services *disco.Disco) getproviders.Source {
provider_source.go:func providerSourceForCLIConfigLocation(loc cliconfig.ProviderInstallationLocation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {

git log -L :providerSource:provider_source.go
commit 8c928e83589d90a031f811fae52a81be7153e82f
Author: Martin Atkins <mart@degeneration.co.uk>
...
+func providerSource(services *disco.Disco) getproviders.Source {
+       // We're not yet using the CLI config here because we've not implemented
...
```

6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.

Список коммитов:
- 78b12205587fe839f10d946ea3fdc06719decb05
- 52dbf94834cb970b510f2fba853a5b49ad9b1a46
- 41ab0aef7a0fe030e84018973a64135b11abcd70
- 66ebff90cdfaa6938f26f908c7ebad8d547fea17
- 8364383c359a6b738a436d1b7745ccdce178df47
```
$ git grep -p 'globalPluginDirs'
commands.go=func initCommands(
commands.go:            GlobalPluginDirs: globalPluginDirs(),
commands.go=func credentialsSource(config *cliconfig.Config) (auth.CredentialsSource, error) {
commands.go:    helperPlugins := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
internal/command/cliconfig/config_unix.go=func homeDir() (string, error) {
internal/command/cliconfig/config_unix.go:              // FIXME: homeDir gets called from globalPluginDirs during init, before
plugins.go=import (
plugins.go:// globalPluginDirs returns directories that should be searched for
plugins.go:func globalPluginDirs() []string {

$ git log -L :globalPluginDirs:plugins.go  -s --format=%H
78b12205587fe839f10d946ea3fdc06719decb05
52dbf94834cb970b510f2fba853a5b49ad9b1a46
41ab0aef7a0fe030e84018973a64135b11abcd70
66ebff90cdfaa6938f26f908c7ebad8d547fea17
8364383c359a6b738a436d1b7745ccdce178df47
```
7. Кто автор функции `synchronizedWriters`? 

Автор:\
`Martin Atkins`
```
$ git log -SsynchronizedWriters --oneline
bdfea50cc8 remove unused
fd4f7eb0b9 remove prefixed io
5ac311e2a9 main: synchronize writes to VT100-faker on Windows.
$ git show -s --format=%an 5ac311e2a9
Martin Atkins
```
