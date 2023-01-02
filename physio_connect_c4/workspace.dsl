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

                requestHandler = container "Request Handler / Load Balancer" {
                    technology "Ingress"
                }

                group "Planung" {
                    planungsService = container "Therapie Planungs Service" {
                        description "Handhabt alle Requests für die Verwaltung von Gesamttherapien. Validiert Requests, beinhaltet Applikations und Domänenlogik für die Planungsdaten"
                        technology "Spring Boot"
                    }
                    planungsDatenbank = container "Therapie Planungs Datenbank" {
                        tags "Database"
                        technology "Relationale oder Dokumentendatenbank"
                        description "Persistiert alle Planungsdaten. Wird evt. mit der Ausführungs Datenbank fusioniert."
                    }
                }

                group "Ausführung" {
                    ausfuehrungsService = container "Ausführungs Service" {
                        description "Handhabt alle Requests, welche von Patienten während der Ausführung der Therapie Sessions abgesetzt werden. Validiert Requests, beinhaltet Applikations und Domänenlogik für die Ausführungsdaten."
                        technology "Spring Boot"
                    }
                    ausfuehrungsDatenbank = container "Ausführungs Datenbank" {
                        tags "Database"
                        technology "Dokuementendatenbank"
                        description "Beinhaltet Daten der ausgeführtne Therapie Sessions, unter anderem Messdaten, Rückmeldungen und effektive Sets und Reps."
                    }
                }

                group "Wrappers" {
                    uebungsKatalogWrapper = container "Übungskatalog Wrapper" {
                        description "Anti-Corrpution Layer für die Kommunikation mit dem Übungskatalog"
                        technology "Spring boot"
                    }   

                    benutzerVerwaltungWrapper = container "Benutzerverwaltung Wrapper" {
                        description "Anti-Corrpution Layer für die Kommunikation mit der Benutzerverwaltung"
                        technology "Spring boot"
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
        patientenApp -> requestHandler "Sendet Messdaten\nSendet Requests für Informationen zu Therapien und Übungen"
        singlePageTherapieManager -> requestHandler  "Sendet Requests zum Verwalten der Gesamttherapien, Übungen und Benutzer"

        requestHandler -> planungsService "Leitet Requests weiter für Gesamttherapien"
        requestHandler -> benutzerVerwaltungWrapper "Leitet Requests weiter für die Benutzerverwaltung"
        requestHandler -> uebungsKatalogWrapper "Leitet Requests weiter für den Übungskatalog"
        requestHandler -> ausfuehrungsService "Leitet ausführungsspezifische Requests weiter"

        ausfuehrungsService -> ausfuehrungsDatenbank "Persistiert Messdaten und effektive Ausführungsinformationen"

        planungsService -> benutzerVerwaltungWrapper "Verwendet Benutzerinformationen von"
        planungsService -> uebungsKatalogWrapper "Verwendet Übungsinformationen von"
        planungsService -> planungsDatenbank "Persistiert Gesamttherapien, Therapie Sessions, Therapie Übungen und die dazugehörigen Detailinformationen"
        planungsService -> ausfuehrungsService "Kombiniert Planugnsdaten mit Ausführungsdaten von"

        benutzerVerwaltungWrapper -> benutzerVerwaltung "Verwaltet Benutzerdaten"
        uebungsKatalogWrapper -> uebungsKatalog "Verwaltet Übungsdefinitionen"

        serverSideTherapieManager -> singlePageTherapieManager "Liefert SPA an den Client aus"
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