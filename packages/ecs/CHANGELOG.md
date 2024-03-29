# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0](https://github.com/aldra-consulting/infrastructure-modules/compare/ecs@0.4.0...ecs@0.5.0) (2023-10-15)


### ⚠ BREAKING CHANGES

* **ecs:** add container_definitions input parameter

### Features

* **ecs:** add container_definitions input parameter ([cf5a527](https://github.com/aldra-consulting/infrastructure-modules/commit/cf5a527bc12bdcc9c9a0a5ad3b401b77508ca6f6))
* **ecs:** add read_only_filesystem configuration parameter ([37a3db0](https://github.com/aldra-consulting/infrastructure-modules/commit/37a3db00109a353aa4eeee29c2ac8a8e1537f24e))
* **ecs:** externalise container image configuration ([349eadc](https://github.com/aldra-consulting/infrastructure-modules/commit/349eadc16fefd099d997cb352a5ab2f9e6909bf5))
* **ecs:** use HTTPS load balancer listensers ([c1f4bb3](https://github.com/aldra-consulting/infrastructure-modules/commit/c1f4bb35404a70d6f448f655d9f6e73a0c9b631a))


### Bug Fixes

* **ecs:** set correct environment parameter type ([2137ed9](https://github.com/aldra-consulting/infrastructure-modules/commit/2137ed99364abbfc301c11ea6fbe022c77d1a241))



## [0.4.0](https://github.com/aldra-consulting/infrastructure-modules/compare/ecs@0.3.1...ecs@0.4.0) (2023-10-13)


### Features

* **ecs:** add task_iam_policy_statements to service definition input ([e9f327f](https://github.com/aldra-consulting/infrastructure-modules/commit/e9f327fe9e17d62680984f4a334a10190120ea96))



## [0.3.1](https://github.com/aldra-consulting/infrastructure-modules/compare/ecs@0.3.0...ecs@0.3.1) (2023-10-09)


### Bug Fixes

* **ecs:** allow all outgoing traffic ([290c779](https://github.com/aldra-consulting/infrastructure-modules/commit/290c779a84b206411ee1f983dfd029fc3bc351ad))



## [0.3.0](https://github.com/aldra-consulting/infrastructure-modules/compare/ecs@0.2.0...ecs@0.3.0) (2023-10-09)


### Features

* **ecs:** add more outputs ([a2e22cf](https://github.com/aldra-consulting/infrastructure-modules/commit/a2e22cf14b79ec7604d3eca78a64596ad2a26346))
* **ecs:** add service cpu and memory parameters ([4b8ffde](https://github.com/aldra-consulting/infrastructure-modules/commit/4b8ffde31eac29dc38b49c703203157c63ccb7bf))
* **ecs:** add service port ([fabd29a](https://github.com/aldra-consulting/infrastructure-modules/commit/fabd29ad78ec6a25ca11539ce1e8c3775f98cf69))


### Bug Fixes

* **ecs:** allocate more resources to each service ([6548dd1](https://github.com/aldra-consulting/infrastructure-modules/commit/6548dd1f712fb69b94a4db82e74f6c3f015cd615))
* **ecs:** change health check configuration ([84b79f0](https://github.com/aldra-consulting/infrastructure-modules/commit/84b79f0a2b5b8ebf03455d69cc022d3a48af43d5))
* **ecs:** use stricter ingress and egress security rules ([406e9d0](https://github.com/aldra-consulting/infrastructure-modules/commit/406e9d0abc7b538e8a23c3496ecb7d6e38632f1e))



## [0.2.0](https://github.com/aldra-consulting/infrastructure-modules/compare/ecs@0.1.1...ecs@0.2.0) (2023-10-05)


### Features

* **ecs:** add support for ECS services ([6faeca0](https://github.com/aldra-consulting/infrastructure-modules/commit/6faeca0d83e3a58e09191e7d842cbe2cbc33e38f))



## [0.1.1](https://github.com/aldra-consulting/infrastructure-modules/compare/ecs@0.1.0...ecs@0.1.1) (2023-10-04)


### Bug Fixes

* **ecs:** use correct ECS module ([d8db78f](https://github.com/aldra-consulting/infrastructure-modules/commit/d8db78fca799a6c06c25181584ca763267dee1a2))



## 0.1.0 (2023-10-04)


### Features

* **ecs:** add ECS module ([ed851f0](https://github.com/aldra-consulting/infrastructure-modules/commit/ed851f0b1f1d1260df3a519630948258f83f29f0))
