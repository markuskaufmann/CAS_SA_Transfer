workspace "Physio integration layer project" {

    model {
        group "Physiounternehmung" {
            therapeut = person "Therapeut: in" "Person, welche Physiotherapien leitet" "therapeut"
            admin = person "Administrator: in" 
            dokumentationsSoftware = softwareSystem "Dokumentationssoftware"
            therapieFile = element "Therapie File" {
                tags "file"
            }
        }

        group "Patient" {
            patient = person "Patient: in" "Patient der jeweiligen Physio Organisation" "Patient"
            fitnessTracker = softwareSystem "Fitness Tracker"
        }

        group "Moegliche zukünftige Abhängigkeiten" {
            patientenDossier = softwareSystem "Patienten Dossier"
            versicherungsSchnittstellen = softwareSystem "Versicherungsschnittstellen"
            dataScientist = person "Data Scientist"
        }

        
        enterprise "Unternehmungsgrenze" {
            physioConnect = softwareSystem "Physio Connect" {
                description "Bietet ein WebApp an zur Verwaltung von Therapie Planugnsdaten und eine Schnittstelle zum Empfangen und Persistieren von Ausführungsdaten."
                tags "mainSystem"
                group "Frontend" {
                    serverSideTherapieManager = container "Server Side Therapie Manager" {
                        description "Liefert auf Anfrage die Single Page Application aus"
                        technology "React"
                    }
                    singlePageTherapieManager = container "Therapien Manager SPA" {
                        description "Single Page Applikation zum Verwalten von Therapiedaten. Kann von mobilen Devices als PWA verwendet werden."
                        technology "Single Page Application, Progressive Web App"
                    }
                }

                loadBalancer = container "Load Balancer" "Reverse Proxy und Load Balancer"

                group "Planung" {
                    planungsService = container "Therapie Planungs Service" {
                        description "Handhabt alle Requests für die Verwaltung von Gesamttherapien. Validiert Requests, beinhaltet Applikations- und Domänenlogik für die Planungsdaten"
                        technology "Spring Boot"

                        therapieApiController = component "Therapie API Controller" "Verwaltet die bereitgestellten API Endpoints des Services, z.B. Verifiziert die eingehenden Requests."
                        therapieApplikationsLogik = component "Therapie Applikationslogik"
                        therapiePersistenzAdapter = component "Therapie Persistenz Adapter"
                        therapieDomaenenLogik = component "Therapie Domänenlogik" "" "POJO"
                        therapieUebungsKatalogApiAdapter = component "Übungskatalog API Adapter" "Verwaltet den serviceinternen Zugriff auf die API des Übungskatalog Wrappers"
                        therapieBenutzerVerwaltungApiAdapter = component "Benutzerverwaltung API Adapter" "Verwaltet den serviceinternen Zugriff auf die API des Benutzerverwaltung Wrappers"
                        therapieAusfuehrungsApiAdapter = component "Ausführungs API Adapter" "Verwaltet den serviceinternen Zugriff auf die API des Ausführungs Service"
                    }
                    planungsDatenbank = container "Therapie Planungs Datenbank" {
                        tags "Database"
                        technology "Relationale oder Dokumentdatenbank"
                        description "Persistiert alle Planungsdaten. Wird evt. mit der Ausführungs Datenbank fusioniert."
                    }
                }

                group "Ausführung" {
                    ausfuehrungsService = container "Ausführungs Service" {
                        description "Handhabt alle Requests, welche von Patienten während der Ausführung der Therapie-Sessions abgesetzt werden. Validiert Requests, beinhaltet Applikations und Domänenlogik für die Ausführungsdaten."
                        technology "Spring Boot"

                        ausfuehrungsApiController = component "Ausführungs API Controller" "Verwaltet die bereitgestellten API Endpoints des Services, z.B. Verifiziert die eingehenden Requests."
                        ausfuehrungsApplikationsLogik = component "Ausführungs Applikationslogik"
                        ausfuehrungsPersistenzAdapter = component "Ausführungs Persistenz Adapter"
                        ausfuehrungsDomaenenLogik = component "Ausführungs Domänenlogik" "" "POJO"
                    }
                    ausfuehrungsDatenbank = container "Ausführungs Datenbank" {
                        tags "Database"
                        technology "Dokumentdatenbank"
                        description "Beinhaltet Daten der ausgeführten Therapie-Sessions: Unter anderem Messdaten, Rückmeldungen und effektive Sets und Reps."
                    }
                }

                group "Wrappers" {
                    uebungsKatalogWrapper = container "Übungskatalog Wrapper" {
                        description "Anti-Corruption Layer (ACL) für die Kommunikation mit dem Übungskatalog"
                        technology "Spring Boot"
                    }

                    benutzerVerwaltungWrapper = container "Benutzerverwaltung Wrapper" {
                        description "Anti-Corruption Layer (ACL) für die Kommunikation mit der Benutzerverwaltung"
                        technology "Spring Boot"
                    }
                }
            }

            patientenApp = softwareSystem "Mobile Patientenapp"
            uebungsKatalog = softwareSystem "Übungskatalog"
            benutzerVerwaltung = softwareSystem "Benutzerverwaltung" "Authentifizierung und Autorisierung"
        
        }
        


        # relationships between people and software systems
        physioConnect -> patient "Sendet Einladung für Therapie"

        admin -> physioConnect "Administriert Personal und Uebungen"
        therapeut -> dokumentationsSoftware "Plant / Dokumentiert Therapien" 

        therapeut -> therapieFile "Editiert" 
        therapeut -> singlePageTherapieManager "Plant Therapien direkt\nsendet Therapieeinladungen\nerstellt eigene Uebungen" 
        dataScientist -> physioConnect "Benutzt Daten"
        patient -> patientenApp "Registriert sich\nNimmt Therapieeinladungen an\nBenutzt App für selbstständige ausführung von Therapien"
        patient -> fitnessTracker "besitzt"
        patient -> singlePageTherapieManager "Verwaltet selbsterstellte Therapien"
        patientenApp -> fitnessTracker "Verbindet sich mit"
        fitnessTracker ->  patientenApp "Sendet Messdaten"

        # relationships to/from software systems
        dokumentationsSoftware -> therapieFile "Exportiert"
        patientenApp -> physioConnect "Sendet Session Updates mit Messdaten, Registrierung neuer Benutzer\n Authentifiziert Benutzer"
        physioConnect -> patientenApp "Sendet Therapien, Sessions und Uebungen"
        physioConnect -> uebungsKatalog "Importiert Uebungen"
        physioConnect -> therapieFile "importiert Uebungen"
        physioConnect -> dokumentationssoftware "importiert Uebungen"
        physioConnect -> benutzerVerwaltung "Autorisiert und Authentifiziert Benutzer\n Erstellt neue Benutzer"
        physioConnect -> patientenDossier "Automatischer Datenaustausch"
        physioConnect -> versicherungsSchnittstellen "teilt Trainingsdaten"
        
        # relationships to/from containers
        patientenApp -> loadBalancer "Sendet Messdaten\nSendet Requests für Informationen zu Therapien und Übungen"
        singlePageTherapieManager -> loadBalancer  "Sendet Requests zum Verwalten der Gesamttherapien, Übungen und Benutzer"

        loadBalancer -> planungsService "Leitet Requests weiter für Gesamttherapien"
        loadBalancer -> benutzerVerwaltungWrapper "Leitet Requests weiter für die Benutzerverwaltung"
        loadBalancer -> uebungsKatalogWrapper "Leitet Requests weiter für den Übungskatalog"
        loadBalancer -> ausfuehrungsService "Leitet ausführungsspezifische Requests weiter"

        ausfuehrungsService -> ausfuehrungsDatenbank "Persistiert Messdaten und effektive Ausführungsinformationen"

        planungsService -> benutzerVerwaltungWrapper "Verwendet Benutzerinformationen von"
        planungsService -> uebungsKatalogWrapper "Verwendet Übungsinformationen von"
        planungsService -> planungsDatenbank "Persistiert Gesamttherapien, Therapie-Sessions, Therapie Übungen und die dazugehörigen Detailinformationen"
        planungsService -> ausfuehrungsService "Kombiniert Planugnsdaten mit Ausführungsdaten von"

        benutzerVerwaltungWrapper -> benutzerVerwaltung "Verwaltet Benutzerdaten"
        uebungsKatalogWrapper -> uebungsKatalog "Verwaltet Übungsdefinitionen"

        serverSideTherapieManager -> singlePageTherapieManager "Liefert SPA an den Client aus"

        # relationships to/from components to/from containers
        therapiePersistenzAdapter -> planungsDatenbank  "Persistiert Daten in"
        therapieUebungsKatalogApiAdapter -> uebungsKatalogWrapper "Sendet API Requests an"
        therapieBenutzerverwaltungApiAdapter -> benutzerVerwaltungWrapper "Sendet API Requests an"
        therapieAusfuehrungsApiAdapter -> ausfuehrungsService "Sendet API Requests an"
        loadBalancer -> therapieApiController "Leitet Requests weiter für Gesamttherapien"

        ausfuehrungsPersistenzAdapter -> ausfuehrungsDatenbank "Persistiert Daten in"
        loadBalancer -> ausfuehrungsApiController "Leitet ausführungsspezifische Requests weiter"
        planungsService -> ausfuehrungsApiController "Sendet API Requests an"

        # relationships to/from components
        therapieApiController -> therapieApplikationsLogik "Führt Service Calls mit den verifizierten Daten aus"
        therapiePersistenzAdapter -> therapieApplikationsLogik "Implementiert Adapter für die Port Interfaces der Applikationslogik"
        therapieApplikationsLogik -> therapieDomaenenLogik "Implementier Adapter für die Port Interfaces der Domänenlogik"
        therapieUebungsKatalogApiAdapter -> therapieApplikationsLogik "Implementiert Adapter für die Port Interfaces der Applikationslogik"
        therapieBenutzerverwaltungApiAdapter -> therapieApplikationsLogik "Implementiert Adapter für die Port Interfaces der Applikationslogik"
        therapieAusfuehrungsApiAdapter -> therapieApplikationsLogik "Implementiert Adapter für die Port Interfaces der Applikationslogik"

        ausfuehrungsApiController -> ausfuehrungsApplikationsLogik "Führt Service Calls mit den verifizierten Daten aus"
        ausfuehrungsPersistenzAdapter -> ausfuehrungsApplikationsLogik "Implementiert Adapter für die Port Interfaces der Applikationslogik"
        ausfuehrungsApplikationsLogik -> ausfuehrungsDomaenenLogik "Implementier Adapter für die Port Interfaces der Domänenlogik"
                
        deploymentEnvironment "Cloud Deployment singuläre Physio Connect Instanz" {
            deploymentNode "Physio Infrastruktur Praxis" {
                deploymentNode "Laptop" {
                    therapeutPraxisLaptop = containerInstance singlePageTherapieManager
                }

                deploymentNode "Mobile Device" {
                    therapeutPraxisMobile = containerInstance singlePageTherapieManager
                }
            }

            deploymentNode "Physio Infrastruktur Reha Klinik" {
                deploymentNode "Desktop Computer" {
                    therapeutRehaDesktop = containerInstance singlePageTherapieManager
                }
            }

            deploymentNode "Patienten Infrastruktur" {
                deploymentNode "Fitness Tracker" {
                    fitnessTrackerInstanz = softwareSystemInstance fitnessTracker
                }

                deploymentNode "Patient Mobile Device" {
                    patientenAppInstanz = softwareSystemInstance patientenApp
                }
            }


            deploymentNode "Cloud Hyperscaler" {
                deploymentNode "Kubernetes Cluster" {
                    deploymentNode "namespace: PhysioConnect" {
                        loadBalancerInstanz = containerInstance loadBalancer

                        ausfuehrungsServiceInstanz = containerInstance ausfuehrungsService
                        planungsServiceInstanz = containerInstance planungsService

                        uebungsKatalogWrapperInstance = containerInstance uebungsKatalogWrapper
                        benutzerVerwaltungWrapperInstance = containerInstance benutzerVerwaltungWrapper

                        serverSideTherapieManagerInstance =  containerInstance serverSideTherapieManager 
                    }
                    deploymentNode "namespace: Übungskatalog" {
                        uebungsKatalogInstanz = softwareSystemInstance uebungsKatalog
                    }
                    deploymentNode "namespace: Benutzerverwaltung" {
                        benutzerVerwaltungInstanz = softwareSystemInstance benutzerVerwaltung
                    }
                    
                }

                deploymentNode "Storage Service" {
                    ausfuehrungsDatenbankInstanz = containerInstance ausfuehrungsDatenbank
                    planungsDatenbankInstanz = containerInstance planungsDatenbank
                }
            }
        }

        deploymentEnvironment "Mehrere Physio Connect Instanzen" {
            mainDeployment = deploymentGroup "Main Deployment" 
            spitalDeployement = deploymentGroup "Spital Deployment" 

            infPraxis = deploymentNode "Physio Infrastruktur Praxis" {
                deploymentNode "Laptop" {
                    therapeutPraxisLaptop2 = containerInstance singlePageTherapieManager mainDeployment
                }

                deploymentNode "Mobile Device" {
                    therapeutPraxisMobile2 = containerInstance singlePageTherapieManager mainDeployment
                }
            }

            infReha = deploymentNode "Physio Infrastruktur Reha Klinik" {
                deploymentNode "Desktop PC" {
                    therapeutRehaDesktop2 = containerInstance singlePageTherapieManager mainDeployment
                }
            }

            infSpital2 = deploymentNode "Physio Infrastruktur Spital 2" {
                deploymentNode "Tablet" {
                    therapeutSpital2Tablet = containerInstance singlePageTherapieManager mainDeployment
                }
            }

            infPatient = deploymentNode "Patienten Infrastruktur" {
                deploymentNode "Fitness Tracker" {
                    fitnessTrackerInstanz2 = softwareSystemInstance fitnessTracker mainDeployment,spitalDeployement
                }

                deploymentNode "Mobile Device" {
                    patientenAppInstanz2 = softwareSystemInstance patientenApp mainDeployment,spitalDeployement
                }
            }

            deploymentNode "Unsere Infrastruktur" {
                deploymentNode "Kubernetes Cluster" {
                    deploymentNode "namespace: PhysioConnect" {
                        mainLoadBalancerInstanz = containerInstance loadBalancer mainDeployment

                        mainAusfuehrungsServiceInstanz = containerInstance ausfuehrungsService mainDeployment
                        mainPlanungsServiceInstanz = containerInstance planungsService mainDeployment

                        mainUebungsKatalogWrapperInstance = containerInstance uebungsKatalogWrapper mainDeployment
                        mainBenutzerVerwaltungWrapperInstance = containerInstance benutzerVerwaltungWrapper mainDeployment

                        mainServerSideTherapieManagerInstance =  containerInstance serverSideTherapieManager mainDeployment
                    }
                }

                storageService = deploymentNode "Storage Service" {
                    mainAusfuehrungsDatenbankInstanz2 = containerInstance ausfuehrungsDatenbank mainDeployment
                    mainPlanungsDatenbankInstanz2 = containerInstance planungsDatenbank mainDeployment
                }
            }

            deploymentNode "Spital Infrastruktur" {
                infSpital1 = deploymentNode "Physio Infrastruktur Spital" {
                    deploymentNode "Desktop" {
                        therapeutLaptopSpital = containerInstance singlePageTherapieManager spitalDeployement
                    }

                    deploymentNode "Mobile Device" {
                        therapeutMobileSpital = containerInstance singlePageTherapieManager spitalDeployement
                    }
                }

                deploymentNode "Bare Metal Cluster" {
                    deploymentNode "namespace: PhysioConnect" {
                        spitalLoadBalancerInstanz = containerInstance loadBalancer spitalDeployement

                        spitalAusfuehrungsServiceInstanz = containerInstance ausfuehrungsService spitalDeployement
                        spitalPlanungsServiceInstanz = containerInstance planungsService spitalDeployement

                        spitalUebungsKatalogWrapperInstance = containerInstance uebungsKatalogWrapper spitalDeployement
                        spitalBenutzerVerwaltungWrapperInstance = containerInstance benutzerVerwaltungWrapper spitalDeployement

                        spitalServerSideTherapieManagerInstance =  containerInstance serverSideTherapieManager spitalDeployement
                    }
                }

                datenbankServer = deploymentNode "Datenbank Server" {
                    spitalAusfuehrungsDatenbankInstanz = containerInstance ausfuehrungsDatenbank spitalDeployement
                    spitalPlanungsDatenbankInstanz = containerInstance planungsDatenbank spitalDeployement
                }
            }

            unbekanntesHosting = deploymentNode "Hosting zu diesem Zeitpunkt unbekannt" {
                mainUebungsKatalogInstanz = softwareSystemInstance uebungsKatalog mainDeployment,spitalDeployement
                
                mainBenutzerVerwaltungInstanz = softwareSystemInstance benutzerVerwaltung mainDeployment,spitalDeployement
            }
        }
    }

    views {
        systemlandscape "Gesamtuebersicht" {
            include *
            autoLayout
        }

        systemlandscape "Kontextdiagram" {
            include *
            exclude dataScientist versicherungsSchnittstellen patientenDossier
            exclude dokumentationsSoftware therapieFile
            autoLayout
        }

        systemcontext physioConnect "IntegrationsSchicht" {
            include *
            animation {
                physioConnect
                patient
            }
            autoLayout
        }

        container physioConnect "Containers" {
            include *
            autoLayout
        }

        component planungsService "PlanungsServiceDetails" {
            include *
            autoLayout
        }

        component ausfuehrungsService "AusfuehrungsServiceDetails" {
            include *
            autoLayout
        }

        deployment physioConnect "Cloud Deployment singuläre Physio Connect Instanz" "deployment-singulaere-physioconnect" {
            include *
            autoLayout
        }

        deployment * "Mehrere Physio Connect Instanzen" "deployment-mehrere-physioconnect-komplett" {
            include *
            autoLayout
        }

        deployment * "Mehrere Physio Connect Instanzen" "deployment-sicht-therapiemanager" {
            include *
            exclude planungsService ausfuehrungsService
            exclude planungsDatenbank ausfuehrungsDatenbank
            exclude patientenApp fitnessTracker
            exclude infPatient datenbankServer storageService
            autoLayout
        }

        deployment * "Mehrere Physio Connect Instanzen" "deployment-sicht-patientenapp" {
            include *
            exclude serverSideTherapieManager
            exclude singlePageTherapieManager
            exclude uebungsKatalog benutzerVerwaltung
            exclude uebungsKatalogWrapper benutzerVerwaltungWrapper
            exclude infSpital1 infSpital2 infReha infPraxis
            exclude unbekanntesHosting
            autoLayout
        }

        styles {
            element "Person" {
                color #FFFFFF
                background #444444
                fontSize 22
                shape Person
            }
            element "file" {
                color #FFFFFF
                background #1168bd
                shape Folder
            }
            element "Group:Physiounternehmung" {
                color #B6862E
            }
            element "Group:Frontend" {
                color #444444
            }
            element "Group:Wrappers" {
                color #444444
            }
            element "Group:Ausführung" {
                color #444444
            }
            element "Group:Planung" {
                color #444444
            }
            element "Group:Patient" {
                color #589FD8
            }
            element "Group:Moegliche zukünftige Abhängigkeiten" {
                color #38094E
            }
            element "Customer" {
                background #08427b
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "mainSystem" {
                background #000000
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
        }
    }
}